import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../core/vocab.dart';
import '../runtime/device.dart';
import '../theme.dart';
import 'widgets.dart';

/// Kotak yang sedang disunting.
class EditBox {
  EditBox(this.label, this.box, {this.group = false});
  String label;
  List<double> box;
  bool group;
}

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => StudioScreenState();
}

class StudioScreenState extends State<StudioScreen> {
  List<Map<String, dynamic>> _items = [];
  String? _dir;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final items = await CustomDataset.items();
    final dir = (await CustomDataset.dir()).path;
    if (mounted) setState(() => (_items = items, _dir = dir));
  }

  /// Dibuka dari Dapur: foto beserta penanda model, untuk dikoreksi.
  Future<void> open(AppState s) async {
    if (s.photo == null) return;
    final boxes = [for (final d in s.detections) EditBox(d.label, [...d.box], group: d.group)];
    await _edit(s.photo!, boxes);
  }

  Future<void> _new() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1280, imageQuality: 90);
    if (x == null) return;
    await _edit(await x.readAsBytes(), []);
  }

  Future<void> _edit(Uint8List bytes, List<EditBox> boxes) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => Scope(state: Scope.of(context), child: _Editor(bytes: bytes, initial: boxes))));
    if (saved == true) reload();
  }

  Future<void> _export() async {
    final d = await CustomDataset.dir();
    final base = (await Device.modelsDir()).parent.path;
    final out = '$base/meira-custom-${DateTime.now().millisecondsSinceEpoch}.zip';
    final enc = ZipFileEncoder()..create(out);
    await enc.addDirectory(d, includeDirName: true);
    await enc.close();
    if (mounted) toast(context, 'Tersimpan: $out');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.only(bottom: 120), children: [
      LargeTitle('Dataset', trailing: IconButton(tooltip: 'Foto baru', onPressed: _new, icon: const Icon(Icons.add_circle_rounded, color: C.accent, size: 28))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: Text('Ajari MEIRA mengenali bahan di dapur Anda. Tandai setiap bahan, satu buah satu kotak. Contoh yang tersimpan akan dipakai pada pelatihan berikutnya.', style: T.subhead),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Section(children: [
          Row2(title: 'Foto baru', leading: const Icon(Icons.photo_camera_rounded, color: C.accent), onTap: _new, trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary)),
          Row2(
            title: 'Ekspor untuk training',
            subtitle: '${_items.length} contoh',
            leading: const Icon(Icons.ios_share_rounded, color: C.accent),
            onTap: _items.isEmpty ? null : _export,
            trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
          ),
        ]),
      ),
      if (_items.isNotEmpty && _dir != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 5 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final it in _items)
                GestureDetector(
                  onLongPress: () async {
                    await CustomDataset.delete(it['id']);
                    reload();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.file(File('$_dir/${it['file']}'), fit: BoxFit.cover),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(10)),
                          child: Text('${(it['objects'] as List).length} label', style: inter(11, weight: FontWeight.w600, color: C.accent)),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      if (_items.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 0), child: Text('Tekan lama untuk menghapus.', style: T.caption)),
    ]);
  }
}

class _Editor extends StatefulWidget {
  const _Editor({required this.bytes, required this.initial});
  final Uint8List bytes;
  final List<EditBox> initial;

  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final List<EditBox> _boxes = [...widget.initial];
  Size? _size;
  int _sel = -1;
  bool _busy = false;
  final _absent = TextEditingController();
  String _license = 'CC BY 4.0';
  String _author = '';
  Offset? _start;
  List<double>? _startBox;
  String _mode = '';

  @override
  void initState() {
    super.initState();
    ui.instantiateImageCodec(widget.bytes).then((c) => c.getNextFrame()).then((f) => setState(() => _size = Size(f.image.width.toDouble(), f.image.height.toDouble())));
    SharedPreferences.getInstance().then((p) => _author = p.getString('studio_author') ?? '');
  }

  @override
  void dispose() {
    _absent.dispose();
    super.dispose();
  }

  /// Usulan kotak dari detektor bahan; pengguna tinggal memeriksa dan membetulkannya.
  Future<void> _autoLabel() async {
    final s = Scope.of(context);
    final vision = s.vision;
    if (vision == null) return;
    setState(() => _busy = true);
    try {
      final res = await vision.detect(await AppState.visionInput(widget.bytes));
      setState(() => _boxes.addAll([for (final d in res.detections) EditBox(d.label, [...d.box], group: d.group)]));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final labeled = _boxes.where((b) => b.label.trim().isNotEmpty).toList();
    final absent = [for (final a in _absent.text.split(',')) ?resolve(a.trim())];
    if (labeled.isEmpty && absent.isEmpty) {
      toast(context, 'Beri label minimal satu kotak');
      return;
    }
    await CustomDataset.save(
      jpeg: widget.bytes,
      width: _size!.width.round(),
      height: _size!.height.round(),
      objects: [
        for (final b in labeled)
          {'key': resolve(b.label), 'label': resolve(b.label) != null ? displayName(resolve(b.label)!) : b.label.trim().toLowerCase(), 'box': [for (final v in b.box) double.parse(v.toStringAsFixed(4))], 'group': b.group},
      ],
      absent: absent,
      author: _author,
      license: _license,
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _panStart(Offset p, Size area) {
    final x = (p.dx / area.width).clamp(0.0, 1.0), y = (p.dy / area.height).clamp(0.0, 1.0);
    if (_sel >= 0) {
      final b = _boxes[_sel].box;
      if ((x - b[2]).abs() * area.width < 22 && (y - b[3]).abs() * area.height < 22) {
        _mode = 'resize';
        _start = Offset(x, y);
        _startBox = [...b];
        return;
      }
    }
    final hit = _boxes.lastIndexWhere((b) => x >= b.box[0] && x <= b.box[2] && y >= b.box[1] && y <= b.box[3]);
    if (hit >= 0) {
      _sel = hit;
      _mode = 'move';
      _startBox = [..._boxes[hit].box];
    } else {
      _boxes.add(EditBox('', [x, y, x, y]));
      _sel = _boxes.length - 1;
      _mode = 'new';
    }
    _start = Offset(x, y);
    setState(() {});
  }

  void _panUpdate(Offset p, Size area) {
    if (_sel < 0 || _start == null) return;
    final x = (p.dx / area.width).clamp(0.0, 1.0), y = (p.dy / area.height).clamp(0.0, 1.0);
    final s = _start!;
    setState(() {
      switch (_mode) {
        case 'new':
          _boxes[_sel].box = [s.dx < x ? s.dx : x, s.dy < y ? s.dy : y, s.dx > x ? s.dx : x, s.dy > y ? s.dy : y];
        case 'resize':
          final b = _startBox!;
          _boxes[_sel].box = [b[0], b[1], x.clamp(b[0] + .02, 1.0), y.clamp(b[1] + .02, 1.0)];
        case 'move':
          final b = _startBox!;
          final dx = (x - s.dx).clamp(-b[0], 1 - b[2]), dy = (y - s.dy).clamp(-b[1], 1 - b[3]);
          _boxes[_sel].box = [b[0] + dx, b[1] + dy, b[2] + dx, b[3] + dy];
      }
    });
  }

  void _panEnd() {
    if (_mode == 'new' && _sel >= 0) {
      final b = _boxes[_sel].box;
      if (b[2] - b[0] < .02 || b[3] - b[1] < .02) {
        _boxes.removeAt(_sel);
        _sel = -1;
      }
    }
    _start = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        leadingWidth: 84,
        title: const Text('Tandai bahan'),
        actions: [TextButton(onPressed: _size == null ? null : _save, child: Text('Simpan', style: inter(16, weight: FontWeight.w600, color: C.accent)))],
      ),
      body: _size == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 32), children: [
              AspectRatio(
                aspectRatio: _size!.width / _size!.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(builder: (context, c) {
                    final area = Size(c.maxWidth, c.maxHeight);
                    return GestureDetector(
                      onPanStart: (d) => _panStart(d.localPosition, area),
                      onPanUpdate: (d) => _panUpdate(d.localPosition, area),
                      onPanEnd: (_) => _panEnd(),
                      onTapDown: (d) {
                        final x = d.localPosition.dx / area.width, y = d.localPosition.dy / area.height;
                        setState(() => _sel = _boxes.lastIndexWhere((b) => x >= b.box[0] && x <= b.box[2] && y >= b.box[1] && y <= b.box[3]));
                      },
                      child: Stack(children: [
                        Positioned.fill(child: Image.memory(widget.bytes, fit: BoxFit.fill)),
                        for (final (i, b) in _boxes.indexed)
                          Positioned(
                            left: b.box[0] * area.width,
                            top: b.box[1] * area.height,
                            width: (b.box[2] - b.box[0]) * area.width,
                            height: (b.box[3] - b.box[1]) * area.height,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == _sel ? Colors.white.withValues(alpha: .15) : null,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: i == _sel ? C.accent : Colors.white, width: i == _sel ? 2.5 : 1.5),
                                ),
                                alignment: Alignment.center,
                                child: Marker(i + 1, size: 24, active: i == _sel),
                              ),
                            ),
                          ),
                      ]),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Text('Seret untuk membuat kotak. Ketuk untuk memilih, seret sudut kanan bawah untuk mengubah ukuran.', style: T.footnote)),
                TextButton(onPressed: _busy ? null : _autoLabel, child: Text(_busy ? 'Melabeli…' : 'Label otomatis')),
              ]),
              const SizedBox(height: 10),
              Section(header: 'Label', children: [
                for (final (i, b) in _boxes.indexed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                    child: Row(children: [
                      NumberBadge(i + 1, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Autocomplete<String>(
                          key: ValueKey('$i-${b.hashCode}'),
                          initialValue: TextEditingValue(text: b.label),
                          optionsBuilder: (v) {
                            final q = v.text.toLowerCase();
                            if (q.isEmpty) return const Iterable<String>.empty();
                            return ingredients.values.where((e) => !e.pantry && (e.nameId.contains(q) || e.nameEn.contains(q))).map((e) => e.nameId).take(6);
                          },
                          onSelected: (v) => setState(() => b.label = v),
                          fieldViewBuilder: (context, ctl, focus, _) => TextField(
                            controller: ctl,
                            focusNode: focus,
                            onTap: () => setState(() => _sel = i),
                            onChanged: (v) => b.label = v,
                            decoration: const InputDecoration(hintText: 'Nama bahan', filled: false, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                          ),
                        ),
                      ),
                      FilterChip(
                        label: const Text('tumpuk'),
                        selected: b.group,
                        onSelected: (v) => setState(() => b.group = v),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        selectedColor: C.accentTint,
                        backgroundColor: C.grouped,
                        showCheckmark: false,
                        labelStyle: inter(12.5, color: b.group ? C.accent : C.secondary),
                      ),
                      IconButton(onPressed: () => setState(() => _boxes.removeAt(i)), icon: const Icon(Icons.remove_circle_rounded, color: C.clay, size: 22)),
                    ]),
                  ),
                if (_boxes.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text('Belum ada kotak.', style: T.subhead)),
              ]),
              Section(header: 'Bahan yang pasti tidak ada', footer: 'Membantu MEIRA belajar menjawab "tidak ada". Pisahkan dengan koma.', children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(controller: _absent, decoration: const InputDecoration(hintText: 'mis. apel, telur', filled: false, border: InputBorder.none)),
                ),
              ]),
              Section(header: 'Lisensi foto', children: [
                for (final l in const ['CC BY 4.0', 'CC0 1.0'])
                  Row2(title: l, onTap: () => setState(() => _license = l), trailing: _license == l ? const Icon(Icons.check_rounded, color: C.accent) : null),
              ]),
            ]),
    );
  }
}

