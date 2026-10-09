import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../theme.dart';
import 'chat.dart';
import 'illustrations.dart';
import '../core/fasting.dart';
import '../core/intake.dart';
import '../core/tools.dart';
import 'cook_grid.dart';
import 'health.dart';
import 'recipe_book.dart';
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

/// Beranda Dapur: sapaan, kolom tanya, foto bahan, jejak masak, program hidup sehat, dan pintasan buku resep.
class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key, required this.onCorrect});
  final void Function(AppState s) onCorrect;

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  Future<void> _pick(AppState s, ImageSource source) => pickPhoto(context, s, source, onCorrect: widget.onCorrect);

  /// Pertanyaan dari beranda memulai percakapan baru di layar percakapan.
  void _ask(AppState s, {String? say}) {
    if (s.busy) return;
    s.newConversation();
    s.setChatMode('resep');
    openChat(context, s, focus: say == null, onCorrect: widget.onCorrect);
    if (say != null) s.send(text: say);
  }

  final _scroll = ScrollController();
  bool _scrolled = false; // panah petunjuk gulir disembunyikan setelah pengguna menggulir

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final past = _scroll.offset > 40;
      if (past != _scrolled) setState(() => _scrolled = past);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return Stack(
      children: [
        ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 16),
          children: [
            FadeIn(child: _header(s)),
            FadeIn(delay: const Duration(milliseconds: 70), child: _askPill(s)),
            const SizedBox(height: 16),
            FadeIn(delay: const Duration(milliseconds: 140), child: _empty(s)),
          ],
        ),
        // panah kecil yang naik turun: tanda bahwa beranda masih berlanjut ke bawah (jejak masak, gizi seimbang)
        Positioned(
          left: 0,
          right: 0,
          // di atas bilah navigasi yang mengambang dan bilah gestur ponsel (keduanya masuk ke padding bawah)
          bottom: MediaQuery.paddingOf(context).bottom + 10,
          child: IgnorePointer(
            ignoring: _scrolled,
            child: AnimatedOpacity(
              opacity: _scrolled ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              child: Center(
                child: GestureDetector(
                  onTap: () => _scroll.animateTo(380, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                  child: const ScrollHint(),
                ),
              ),
            ),
          ),
        ),
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
      const SizedBox(height: 16),
      const FadeIn(delay: Duration(milliseconds: 200), child: CookJourneyCard()),
      const SizedBox(height: 16),
      FadeIn(delay: const Duration(milliseconds: 260), child: _health(s)),
      const SizedBox(height: 16),
      FadeIn(delay: const Duration(milliseconds: 320), child: _book(s)),
    ],
  );

  /// Program hidup sehat: ajakan memulai, atau rencana makan hari ini bila program sudah berjalan.
  Widget _health(AppState s) {
    final eaten = s.intakeToday.fold(const Nutrients(), (a, e) => a + e.nutrients);
    final f = s.fasting;
    final st = f == null ? null : fastingState(f, DateTime.now());
    Widget pill(IconData icon, String value, String label, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: poppins(15, weight: FontWeight.w700, color: C.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: inter(11, color: C.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Pressable(
      child: Material(
        color: C.herbTint,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => openHealth(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: C.herb),
                    const SizedBox(width: 8),
                    Expanded(child: Text(programName, style: T.headline)),
                    const Icon(Icons.chevron_right_rounded, color: C.secondary),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    pill(Icons.local_fire_department_outlined, '${eaten.energy.round()}', 'kkal', C.accent),
                    const SizedBox(width: 8),
                    s.needs == null
                        ? pill(Icons.monitor_weight_outlined, 'IMT', 'isi data', C.violet)
                        : pill(Icons.monitor_weight_outlined, fmt(s.needs!.bmi), 'IMT', C.violet),
                    const SizedBox(width: 8),
                    st == null
                        ? pill(Icons.schedule_rounded, 'Mati', 'jendela makan', C.blue)
                        : pill(
                            Icons.schedule_rounded,
                            clock(st.eating ? s.fasting!.endMinute : s.fasting!.startMinute),
                            st.eating ? 'jendela tutup' : 'jendela buka',
                            C.blue,
                          ),
                  ],
                ),
                const SizedBox(height: 10),
                const TasteToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Pintasan ke buku resep lengkap; daftar resep tidak lagi memenuhi beranda.
  Widget _book(AppState s) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(22)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Buku resep', style: T.headline)),
            Text('${s.recipes.length} resep', style: T.footnote),
          ],
        ),
        const SizedBox(height: 10),
        RecipeFilterChips(selected: -1, onSelected: (i) => openRecipeBook(context, filter: i)),
        const SizedBox(height: 10),
        Pressable(
          child: OutlinedButton.icon(
            onPressed: () => openRecipeBook(context),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Buka buku resep'),
          ),
        ),
      ],
    ),
  );
}
