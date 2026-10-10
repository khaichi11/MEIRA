import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../theme.dart';
import '../core/tools.dart';
import 'cooking_loader.dart';
import 'photo.dart';
import 'recipe.dart';
import 'routes.dart';
import 'widgets.dart';

/// Buka layar percakapan di atas beranda (tanpa bilah navigasi, dengan tombol kembali).
void openChat(BuildContext context, AppState s, {bool focus = false, void Function(AppState s)? onCorrect}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      settings: const RouteSettings(name: ChatScreen.route),
      builder: (_) => Scope(
        state: s,
        child: ChatScreen(autofocus: focus, onCorrect: onCorrect),
      ),
    ),
  );
}

/// Percakapan satu sesi: foto berpenanda, kartu resep, jawaban, dan kolom tanya di bawah.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.autofocus = false, this.onCorrect});
  static const route = 'percakapan';
  final bool autofocus;
  final void Function(AppState s)? onCorrect;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  bool _boxes = false;
  int _lastCount = 0;
  double _inset = 0; // tinggi papan ketik pada bingkai sebelumnya

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  AppState? _state; // disimpan agar suara bisa dihentikan saat layar ditutup

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_state == null) {
      _state = Scope.of(context);
      // Whisper dimuat saat layar percakapan dibuka, supaya ucapan pertama tidak menunggu lama
      _state!.voiceReady(true);
    }
  }

  @override
  void dispose() {
    // keluar dari percakapan menghentikan suara yang masih dibacakan dan percakapan suara
    _state?.stopSpeaking();
    _state?.endVoiceChat();
    _state?.voiceReady(false);
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Tambah bahan dari foto lain (kamera atau galeri) tanpa memulai percakapan baru.
  Future<void> _addPhoto(AppState s) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
      if (x != null) await s.addPhoto(await x.readAsBytes());
    } catch (e) {
      if (mounted) toast(context, 'Foto tidak bisa dibuka');
    }
  }

  void _send(AppState s, [String? preset]) {
    final t = (preset ?? _text.text).trim();
    if (t.isEmpty) return;
    if (preset == null) _text.clear();
    s.send(text: t);
  }

  Future<void> _mic(AppState s) async {
    final err = await s.toggleMic();
    if (err != null && mounted) toast(context, err);
  }

  /// Saat jawaban sedang "diketik", layar ikut turun bila pengguna memang sedang berada di bawah.
  void _followBottom() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent - pos.pixels < 160) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    }
  }

  void _autoScroll(AppState s) {
    final count = s.messages.length + (s.messages.isEmpty ? 0 : s.messages.last.text.length ~/ 40);
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    _autoScroll(s);
    // saat papan ketik naik, pesan terakhir tetap terlihat seperti aplikasi percakapan pada umumnya
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    if (inset > _inset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });
    }
    _inset = inset;
    final title = s.photo == null
        ? 'Percakapan'
        : s.sceneMode == 'hidangan'
        ? (s.dish ?? 'Makanan jadi')
        : 'Bahan di foto';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: Text(title),
        // satu asisten dengan dua fokus: resep (bahan, masakan) atau gizi (catatan makan, berat, puasa, label kemasan)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'resep', label: Text('Resep'), icon: Icon(Icons.restaurant_rounded, size: 18)),
                ButtonSegment(value: 'gizi', label: Text('Gizi'), icon: Icon(Icons.eco_rounded, size: 18)),
              ],
              selected: {s.chatMode},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(inter(13.5, weight: FontWeight.w600)),
                backgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? C.accentTint : C.surface),
                foregroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? C.accentDeep : C.secondary),
                side: const WidgetStatePropertyAll(BorderSide(color: C.separator)),
              ),
              onSelectionChanged: s.busy ? null : (v) => s.setChatMode(v.first),
            ),
          ),
        ),
        actions: [
          // tombol hentikan suara dan menu foto ada di bilah atas, jadi tetap terjangkau setelah percakapan panjang
          if (s.voice == VoiceState.speaking)
            IconButton(
              tooltip: 'Hentikan suara',
              onPressed: s.stopSpeaking,
              icon: const Icon(Icons.volume_off_rounded, color: C.accent),
            ),
          IconButton(tooltip: 'Tambah bahan dari foto', onPressed: s.busy ? null : () => _addPhoto(s), icon: const Icon(Icons.add_a_photo_outlined)),
          if (s.photo != null) _photoMenu(s, inBar: true),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              children: [if (s.photo != null) _photoBlock(s), const SizedBox(height: 8), ..._conversation(s)],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, a) => SizeTransition(
              sizeFactor: a,
              child: FadeTransition(opacity: a, child: child),
            ),
            child: s.handsFree
                ? _voiceChat(s)
                : s.voice == VoiceState.speaking
                ? _stopVoice(s)
                : const SizedBox.shrink(),
          ),
          _suggestions(s),
          _composer(s),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- foto
  Widget _photoBlock(AppState s) {
    if (s.photo == null) return const SizedBox.shrink();
    return FadeIn(
      key: ObjectKey(s.photo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              PhotoView(state: s, showBoxes: _boxes),
              Positioned(top: 10, right: 10, child: _photoMenu(s)),
              if (s.sceneMode != null)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      s.sceneMode == 'hidangan' ? (s.dish ?? 'Makanan jadi') : 'Bahan',
                      style: inter(13, weight: FontWeight.w600, color: C.accent),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SeenList(state: s),
          if (s.detectSeconds != null && s.detections.isNotEmpty)
            FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 2),
                child: Text('Dibaca dalam ${s.detectSeconds!.toStringAsFixed(1)} detik', style: T.caption),
              ),
            ),
          if (s.currentMatch != null) ...[
            const SizedBox(height: 14),
            FadeIn(
              delay: const Duration(milliseconds: 120),
              offset: 18,
              child: RecipeCard(state: s),
            ),
          ],
        ],
      ),
    );
  }

  /// Tombol besar untuk menghentikan suara yang sedang dibacakan, misalnya bila tombol suara tidak sengaja tertekan.
  Widget _stopVoice(AppState s) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Pressable(
      child: Material(
        color: C.accentTint,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: s.stopSpeaking,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stop_circle_rounded, color: C.accentDeep, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Hentikan suara',
                  style: inter(14.5, weight: FontWeight.w600, color: C.accentDeep),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  /// Percakapan suara sedang berjalan: gelombang kecil mengikuti keadaan (mendengar, menulis, membacakan), dan tombol
  /// untuk mematikannya.
  Widget _voiceChat(AppState s) {
    final label = switch (s.voice) {
      VoiceState.listening => 'Mendengarkan…',
      VoiceState.transcribing => 'Menulis ucapan Anda…',
      VoiceState.speaking => 'Membacakan jawaban…',
      _ => 'Percakapan suara aktif',
    };
    return Padding(
      key: const ValueKey('suara'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            VoiceWave(active: s.voice == VoiceState.listening || s.voice == VoiceState.speaking, level: s.speech?.level.stream),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: inter(14, weight: FontWeight.w600, color: C.accentDeep),
              ),
            ),
            TextButton(onPressed: s.endVoiceChat, child: const Text('Matikan')),
          ],
        ),
      ),
    );
  }

  Widget _photoMenu(AppState s, {bool inBar = false}) => Material(
    color: inBar ? Colors.transparent : Colors.white.withValues(alpha: .92),
    shape: const CircleBorder(),
    child: PopupMenuButton<String>(
      tooltip: 'Menu foto',
      icon: Icon(inBar ? Icons.more_vert_rounded : Icons.more_horiz_rounded, color: C.label),
      color: C.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) async {
        switch (v) {
          case 'boxes':
            setState(() => _boxes = !_boxes);
          case 'bahan' || 'hidangan' || 'otomatis':
            await s.setPref('photo_mode', v);
            if (s.photo != null && !s.busy) await s.sendPhoto(s.photo!);
          case 'correct':
            Navigator.pop(context);
            widget.onCorrect?.call(s);
          case 'save':
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: C.bg,
                title: Text('Simpan ke dataset?', style: T.headline),
                content: Text(
                  'Pastikan setiap bahan sudah bernomor dan tidak ada nomor yang salah. Foto ini akan dipakai untuk melatih MEIRA berikutnya.',
                  style: T.callout,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
                ],
              ),
            );
            if (ok == true) {
              final id = await s.saveToDataset();
              if (mounted && id != null) toast(context, 'Tersimpan di Dataset');
            }
        }
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(value: 'boxes', checked: _boxes, child: const Text('Tampilkan kotak')),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(value: 'otomatis', checked: s.photoMode == 'otomatis', child: const Text('Kenali otomatis')),
        CheckedPopupMenuItem(value: 'bahan', checked: s.photoMode == 'bahan', child: const Text('Ini bahan mentah')),
        CheckedPopupMenuItem(value: 'hidangan', checked: s.photoMode == 'hidangan', child: const Text('Ini makanan jadi')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'correct', child: Text('Edit kotak di Dataset')),
        const PopupMenuItem(value: 'save', child: Text('Semua benar, simpan ke dataset')),
      ],
    ),
  );

  // ------------------------------------------------------------- percakapan
  List<Widget> _conversation(AppState s) => [
    for (final m in s.messages)
      FadeIn(
        key: ObjectKey(m),
        // pesan pengguna masuk dari kanan, jawaban MEIRA dari kiri
        dx: m.role == Role.user ? 18 : -12,
        scale: .97,
        child: switch (m.role) {
          Role.user => Align(
            alignment: Alignment.centerRight,
            child: m.text.isEmpty
                ? (m.photo != null && s.messages.indexOf(m) > 0
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(m.photo!, width: 140, height: 140, fit: BoxFit.cover),
                          ),
                        )
                      : const SizedBox.shrink())
                : Container(
                    margin: const EdgeInsets.only(left: 56, top: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: const BoxDecoration(
                      color: C.accentTint,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                    child: Text(m.text, style: inter(16, height: 1.4)),
                  ),
          ),
          Role.meira => Padding(
            padding: const EdgeInsets.only(top: 14, right: 24),
            child: m.streaming && m.text.isEmpty
                ? const TypingDots()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TypingText(key: ObjectKey(m), message: m, onNumber: (n) => s.highlight(n == null ? [] : [n]), onGrow: _followBottom),
                      // tombol aksi: jawaban yang menyangkut fitur bisa langsung membuka fiturnya
                      if (m.actions.isNotEmpty && !m.streaming)
                        FadeIn(
                          delay: const Duration(milliseconds: 250),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(spacing: 8, runSpacing: 8, children: [for (final r in m.actions) _action(r)]),
                          ),
                        ),
                    ],
                  ),
          ),
          Role.status => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const CookingLoader(size: 44),
                const SizedBox(width: 8),
                Text(m.text, style: T.subhead),
              ],
            ),
          ),
          Role.error => Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(m.text, style: inter(14, color: C.clay)),
          ),
        },
      ),
  ];

  Widget _action(String route) => Pressable(
    child: ActionChip(
      avatar: Icon(
        switch (route) {
          'gizi' => Icons.eco_rounded,
          'tubuh' => Icons.monitor_weight_outlined,
          'resep' => Icons.menu_book_rounded,
          'puasa' => Icons.schedule_rounded,
          _ => Icons.arrow_forward_rounded,
        },
        size: 18,
        color: C.accentDeep,
      ),
      label: Text(routeLabels[route] ?? route),
      labelStyle: inter(13.5, weight: FontWeight.w600, color: C.accentDeep),
      backgroundColor: C.accentTint,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      onPressed: () => openRoute(context, route),
    ),
  );

  Widget _suggestions(AppState s) {
    if (s.busy || s.voice != VoiceState.idle) return const SizedBox.shrink();
    if (s.session == null && s.chatMode != 'gizi') return const SizedBox.shrink();
    final dish = s.sceneMode == 'hidangan';
    final items = s.chatMode == 'gizi' && s.currentMatch == null && s.session?.label == null
        ? const [
            ('Makanan saya hari ini', 'Hari ini saya makan apa saja? Masih aman?'),
            ('Boleh makan sekarang?', 'Boleh makan sekarang?'),
            ('Kebutuhan harian saya', 'Berapa kebutuhan kalori saya?'),
            ('Progres berat', 'Gimana progres berat saya?'),
          ]
        : s.session?.label != null
        ? const [('Kalau dimakan semua?', 'Kalau saya makan semuanya gimana?'), ('Porsi yang pas', 'Sebaiknya berapa sajian?')]
        : dish
        ? const [('Bahannya apa saja?', 'Bahannya apa saja?'), ('Cara membuat', 'Bagaimana cara membuatnya?')]
        : s.currentMatch != null
        ? const [
            ('Resep lain', 'Ganti resep yang lain'),
            ('Cara membuat', 'Bagaimana cara membuatnya?'),
            ('Lebih cepat', 'Yang lebih cepat, maksimal 15 menit'),
          ]
        : const <(String, String)>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final recipe = s.currentMatch?.recipe;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        children: [
          // resep yang sedang disarankan selalu bisa dibuka dari sini, tanpa menggulir kembali ke kartu di atas
          if (recipe != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ActionChip(
                  key: ValueKey(recipe.name),
                  avatar: const Icon(Icons.menu_book_rounded, size: 18, color: Colors.white),
                  label: Text(recipe.name),
                  onPressed: () => showRecipeDetail(context, s, recipe),
                  labelStyle: inter(14, weight: FontWeight.w600, color: Colors.white),
                  backgroundColor: C.accent,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
              ),
            ),
          for (final (label, say) in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(label),
                onPressed: () => _send(s, say),
                labelStyle: inter(14, weight: FontWeight.w500, color: C.accentDeep),
                backgroundColor: C.accentTint,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _composer(AppState s) {
    final hasText = _text.text.trim().isNotEmpty;
    final live = s.voice == VoiceState.listening;
    final transcribing = s.voice == VoiceState.transcribing;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: C.separator),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CallbackShortcuts(
                        bindings: {const SingleActivator(LogicalKeyboardKey.enter): () => _send(s)},
                        child: TextField(
                          // tanpa saran kata dari papan ketik, supaya tidak muncul usulan kata yang tidak pantas
                          autocorrect: false,
                          enableSuggestions: false,
                          controller: _text,
                          autofocus: widget.autofocus,
                          minLines: 1,
                          maxLines: 5,
                          style: T.body,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(s),
                          decoration: InputDecoration(
                            hintText: live
                                ? 'Mendengarkan…'
                                : transcribing
                                ? 'Menulis ucapan Anda…'
                                : s.chatMode == 'gizi'
                                ? 'Tanya soal gizi atau catat makanan'
                                : 'Tanya soal resep atau bahan',
                            filled: false,
                            contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, a) => ScaleTransition(
                          scale: a,
                          child: FadeTransition(opacity: a, child: child),
                        ),
                        child: hasText
                            ? KeyedSubtree(
                                key: const ValueKey('kirim'),
                                child: _round(Icons.arrow_upward_rounded, s.busy ? null : () => _send(s), C.accent, Colors.white, size: 36),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('mik'),
                                child: _MicButton(state: s, onTap: () => _mic(s)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback? onTap, Color bg, Color fg, {double size = 44}) => Material(
    color: onTap == null ? bg.withValues(alpha: .5) : bg,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: fg, size: size * .5),
      ),
    ),
  );
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.state, required this.onTap});
  final AppState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final live = state.voice == VoiceState.listening;
    final busy = state.voice == VoiceState.transcribing;
    return StreamBuilder<double>(
      stream: state.speech?.level.stream,
      initialData: 0,
      builder: (_, snap) {
        final lvl = live ? (snap.data ?? 0) : 0.0;
        return SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (live)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  width: 36 + lvl * 22,
                  height: 36 + lvl * 22,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: C.herb.withValues(alpha: .22)),
                ),
              Material(
                color: live ? C.accent : Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: busy ? null : onTap,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: busy
                        ? const Padding(padding: EdgeInsets.all(9), child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(live ? Icons.stop_rounded : Icons.mic_none_rounded, color: live ? Colors.white : C.secondary, size: 21),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
