import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../core/recipes.dart';
import '../theme.dart';
import 'chat.dart';
import 'illustrations.dart';
import 'recipe.dart';
import 'widgets.dart';

/// Ambil atau pilih foto lalu kirim ke MEIRA. Dari beranda, layar percakapan dibuka lebih dulu.
Future<void> pickPhoto(
  BuildContext context,
  AppState s,
  ImageSource source, {
  String text = '',
  bool inChat = false,
  void Function(AppState s)? onCorrect,
}) async {
  try {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 88);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!inChat && context.mounted) openChat(context, s, onCorrect: onCorrect);
    await s.sendPhoto(bytes, text: text);
  } catch (e) {
    if (context.mounted) toast(context, 'Foto tidak bisa dibuka');
  }
}

/// Beranda Dapur: sapaan, kolom tanya, foto bahan, foto terakhir, dan buku resep.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key, required this.onCorrect});
  final void Function(AppState s) onCorrect;

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int _filter = 0;
  bool _allRecipes = false;

  Future<void> _pick(AppState s, ImageSource source) => pickPhoto(context, s, source, onCorrect: widget.onCorrect);

  /// Pertanyaan dari beranda memulai percakapan baru di layar percakapan.
  void _ask(AppState s, {String? say}) {
    if (s.busy) return;
    s.newConversation();
    openChat(context, s, focus: say == null, onCorrect: widget.onCorrect);
    if (say != null) s.send(text: say);
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 16),
      children: [
        FadeIn(child: _header(s)),
        FadeIn(delay: const Duration(milliseconds: 70), child: _askPill(s)),
        const SizedBox(height: 16),
        FadeIn(delay: const Duration(milliseconds: 140), child: _empty(s)),
      ],
    );
  }

  Widget _askPill(AppState s) => Material(
    color: C.surface,
    borderRadius: BorderRadius.circular(26),
    child: InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => _ask(s),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: C.separator),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: C.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Tanya soal resep atau bahan', style: inter(15.5, color: C.tertiary)),
            ),
            const Icon(Icons.mic_none_rounded, color: C.secondary),
          ],
        ),
      ),
    ),
  );

  Widget _header(AppState s) {
    final h = DateTime.now().hour;
    final time = h < 11
        ? 'Selamat pagi'
        : h < 15
        ? 'Selamat siang'
        : h < 18
        ? 'Selamat sore'
        : 'Selamat malam';
    final name = s.userName?.trim() ?? '';
    final greet = name.isEmpty ? time : '$time, $name';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 0, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greet, style: inter(14, color: C.secondary)),
                const SizedBox(height: 2),
                Text('Mau masak apa hari ini?', style: poppins(24, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppState s) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      // kartu utama: ilustrasi mangkuk dan dua cara memasukkan foto
      Container(
        height: 286,
        decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(28)),
        child: Stack(
          children: [
            const Positioned(right: -18, top: -6, child: Floating(child: ProduceBowl(size: 230))),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 170,
                    child: Text('Foto bahan, temukan resepnya', style: poppins(23, color: Colors.white, height: 1.2)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Pressable(
                          child: FilledButton.icon(
                            onPressed: () => _pick(s, ImageSource.camera),
                            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: C.accentDeep),
                            icon: const Icon(Icons.photo_camera_rounded),
                            label: const Text('Kamera'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Pressable(
                          child: FilledButton.icon(
                            onPressed: () => _pick(s, ImageSource.gallery),
                            style: FilledButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .22), foregroundColor: Colors.white),
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('Galeri'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _recipes(s),
    ],
  );

  static final _filters = <(String, bool Function(Recipe))>[
    ('Semua', (_) => true),
    ('Cepat', (r) => r.minutes <= 15),
    ('Sarapan', (r) => r.tags.contains('sarapan')),
    ('Tanpa kompor', (r) => r.tags.contains('tanpa-kompor')),
    ('Minuman', (r) => r.tags.contains('minuman')),
    ('Berkuah', (r) => r.tags.contains('berkuah')),
  ];

  /// Buku resep yang bisa dijelajahi tanpa foto, dengan saringan sederhana.
  Widget _recipes(AppState s) {
    final (_, test) = _filters[_filter];
    final list = s.recipes.where(test).toList();
    final shown = _allRecipes ? list : list.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Text('Resep', style: T.title)),
            Text('${list.length} resep', style: T.footnote),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(_filters[i].$1),
              selected: _filter == i,
              onSelected: (_) => setState(() {
                _filter = i;
                _allRecipes = false;
              }),
              showCheckmark: false,
              labelStyle: inter(14, weight: FontWeight.w500, color: _filter == i ? Colors.white : C.label),
              selectedColor: C.accent,
              backgroundColor: C.surface,
              side: BorderSide(color: _filter == i ? C.accent : C.separator),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, r) in shown.indexed)
          FadeIn(
            // kunci ikut saringan supaya daftar masuk ulang dengan berurutan saat saringan diganti
            key: ValueKey('$_filter/${r.name}'),
            delay: Duration(milliseconds: 45 * (i % 6)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Pressable(
                child: Material(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => showRecipeDetail(context, s, r),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(14)),
                            child: Icon(_iconFor(r), color: C.accentDeep, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: inter(15.5, weight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${r.minutes} menit  ·  ${r.items.where((i) => i.main).map((i) => i.name).join(', ')}',
                                  style: T.footnote,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: C.tertiary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (list.length > shown.length)
          TextButton(onPressed: () => setState(() => _allRecipes = true), child: Text('Lihat ${list.length - shown.length} resep lainnya')),
      ],
    );
  }

  static IconData _iconFor(Recipe r) => r.tags.contains('minuman')
      ? Icons.local_cafe_outlined
      : r.tags.contains('berkuah')
      ? Icons.soup_kitchen_outlined
      : r.tags.contains('sarapan')
      ? Icons.egg_outlined
      : r.tags.contains('camilan')
      ? Icons.cookie_outlined
      : Icons.restaurant_outlined;
}
