import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../theme.dart';
import 'photo.dart';
import 'recipe.dart';
import 'widgets.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key, required this.onCorrect});
  final void Function(AppState s) onCorrect;

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  bool _boxes = false;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _mobile => Platform.isAndroid || Platform.isIOS;

  Future<void> _pick(AppState s, ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
      if (x == null) return;
      final text = _text.text.trim();
      _text.clear();
      await s.sendPhoto(await x.readAsBytes(), text: text);
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
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final header = LargeTitle('Dapur', trailing: IconButton(tooltip: 'Percakapan baru', onPressed: s.busy ? null : s.newConversation, icon: const Icon(Icons.edit_square, color: C.sageDeep)));
    if (wide) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 11,
          child: ListView(padding: const EdgeInsets.fromLTRB(4, 0, 12, 24), children: [header, Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _photoBlock(s))]),
        ),
        Expanded(
          flex: 10,
          child: Column(children: [
            Expanded(child: ListView(controller: _scroll, padding: const EdgeInsets.fromLTRB(16, 68, 20, 12), children: _conversation(s))),
            _suggestions(s),
            _composer(s),
          ]),
        ),
      ]);
    }
    return Column(children: [
      Expanded(
        child: ListView(controller: _scroll, padding: const EdgeInsets.only(bottom: 12), children: [
          header,
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _photoBlock(s)),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _conversation(s))),
        ]),
      ),
      _suggestions(s),
      _composer(s),
    ]);
  }

  // ------------------------------------------------------------- foto
  Widget _photoBlock(AppState s) {
    if (s.photo == null) return _empty(s);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Stack(children: [
        PhotoView(state: s, showBoxes: _boxes),
        Positioned(top: 10, right: 10, child: _photoMenu(s)),
        if (s.sceneMode != null)
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(20)),
              child: Text(s.sceneMode == 'hidangan' ? (s.dish ?? 'Makanan jadi') : 'Bahan', style: inter(13, weight: FontWeight.w600, color: C.sageDeep)),
            ),
          ),
      ]),
      const SizedBox(height: 14),
      SeenList(state: s),
      if (s.detectSeconds != null && s.detections.isNotEmpty)
        Padding(padding: const EdgeInsets.only(top: 8, left: 2), child: Text('Dibaca dalam ${s.detectSeconds!.toStringAsFixed(1)} detik', style: T.caption)),
      if (s.currentMatch != null) ...[const SizedBox(height: 14), RecipeCard(state: s)],
    ]);
  }

  Widget _photoMenu(AppState s) => Material(
        color: Colors.white.withValues(alpha: .92),
        shape: const CircleBorder(),
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded, color: C.label),
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
                widget.onCorrect(s);
            }
          },
          itemBuilder: (_) => [
            CheckedPopupMenuItem(value: 'boxes', checked: _boxes, child: const Text('Tampilkan kotak')),
            const PopupMenuDivider(),
            CheckedPopupMenuItem(value: 'otomatis', checked: s.photoMode == 'otomatis', child: const Text('Kenali otomatis')),
            CheckedPopupMenuItem(value: 'bahan', checked: s.photoMode == 'bahan', child: const Text('Ini bahan mentah')),
            CheckedPopupMenuItem(value: 'hidangan', checked: s.photoMode == 'hidangan', child: const Text('Ini makanan jadi')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'correct', child: Text('Perbaiki penanda')),
          ],
        ),
      );

  Widget _empty(AppState s) => Container(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
        decoration: card(),
        child: Column(children: [
          const LogoMark(size: 56),
          const SizedBox(height: 18),
          Text('Apa yang ada di dapurmu?', textAlign: TextAlign.center, style: T.title),
          const SizedBox(height: 8),
          Text('Foto bahan atau makanan jadi. MEIRA menandai yang terlihat, lalu mencarikan resep yang cocok.', textAlign: TextAlign.center, style: T.subhead),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () => _pick(s, _mobile ? ImageSource.camera : ImageSource.gallery), child: Text(_mobile ? 'Ambil foto' : 'Pilih foto')),
          ),
          if (_mobile) TextButton(onPressed: () => _pick(s, ImageSource.gallery), child: const Text('Pilih dari galeri')),
        ]),
      );

  // ------------------------------------------------------------- percakapan
  List<Widget> _conversation(AppState s) => [
        for (final m in s.messages)
          switch (m.role) {
            Role.user => Align(
                alignment: Alignment.centerRight,
                child: m.text.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        margin: const EdgeInsets.only(left: 56, top: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: C.sageTint, borderRadius: BorderRadius.circular(18)),
                        child: Text(m.text, style: T.body),
                      ),
              ),
            Role.meira => Padding(
                padding: const EdgeInsets.only(top: 14, right: 24),
                child: AnswerText(m.text + (m.streaming ? ' ▍' : ''), onNumber: (n) => s.highlight(n == null ? [] : [n])),
              ),
            Role.status => Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.8)),
                  const SizedBox(width: 10),
                  Text(m.text, style: T.subhead),
                ]),
              ),
            Role.error => Padding(padding: const EdgeInsets.only(top: 14), child: Text(m.text, style: inter(14, color: C.clay))),
          },
      ];

  Widget _suggestions(AppState s) {
    if (s.session == null || s.busy || s.voice != VoiceState.idle) return const SizedBox.shrink();
    final dish = s.sceneMode == 'hidangan';
    final items = dish
        ? const [('Bahannya apa saja?', 'Bahannya apa saja?'), ('Cara membuat', 'Bagaimana cara membuatnya?')]
        : s.currentMatch != null
            ? const [('Resep lain', 'Ganti resep yang lain'), ('Cara membuat', 'Bagaimana cara membuatnya?'), ('Lebih cepat', 'Yang lebih cepat, maksimal 15 menit')]
            : const <(String, String)>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 4, 16, 4), children: [
        for (final (label, say) in items)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(label),
              onPressed: () => _send(s, say),
              labelStyle: inter(14, weight: FontWeight.w500, color: C.sageDeep),
              backgroundColor: C.surface,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
      ]),
    );
  }

  Widget _composer(AppState s) {
    final hasText = _text.text.trim().isNotEmpty;
    final live = s.voice == VoiceState.listening;
    final transcribing = s.voice == VoiceState.transcribing;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _round(Icons.photo_camera_rounded, s.busy ? null : () => _pick(s, _mobile ? ImageSource.camera : ImageSource.gallery), C.grouped, C.sageDeep),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: C.separator)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: CallbackShortcuts(
                    bindings: {const SingleActivator(LogicalKeyboardKey.enter): () => _send(s)},
                    child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 5,
                      style: T.body,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(s),
                      decoration: InputDecoration(
                        hintText: live ? 'Mendengarkan…' : transcribing ? 'Menulis ucapanmu…' : 'Tanya MEIRA',
                        filled: false,
                        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: hasText
                      ? _round(Icons.arrow_upward_rounded, s.busy ? null : () => _send(s), C.sageDeep, Colors.white, size: 36)
                      : _MicButton(state: s, onTap: () => _mic(s)),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback? onTap, Color bg, Color fg, {double size = 44}) => Material(
        color: onTap == null ? bg.withValues(alpha: .5) : bg,
        shape: const CircleBorder(),
        child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: size, height: size, child: Icon(icon, color: fg, size: size * .5))),
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
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            if (live)
              AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                width: 36 + lvl * 22,
                height: 36 + lvl * 22,
                decoration: BoxDecoration(shape: BoxShape.circle, color: C.sage.withValues(alpha: .22)),
              ),
            Material(
              color: live ? C.sageDeep : Colors.transparent,
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
          ]),
        );
      },
    );
  }
}
