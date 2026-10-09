import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

/// Tur singkat untuk pengguna baru: enam halaman pendek tentang fitur utama. Bisa dilewati kapan saja, dan bisa dibuka
/// lagi dari Pengaturan.
const _pages = [
  (
    Icons.photo_camera_rounded,
    'Foto bahan, temukan resepnya',
    'Foto bahan di dapur. MEIRA menandai setiap bahan dengan nomor dan menyarankan resep dari buku resep.',
  ),
  (
    Icons.forum_rounded,
    'Tanya apa saja soal makanan',
    'Ketik atau ucapkan pertanyaan, misalnya beda rendang dan kalio atau kandungan gizi alpukat. Bila ada nomor yang salah, ketik misalnya "ini buah naga".',
  ),
  (
    Icons.soup_kitchen_rounded,
    'Masak langkah demi langkah',
    'Mode memasak menampilkan satu langkah per layar dengan pengatur waktu dan bisa dibacakan. Tombol hentikan suara selalu tersedia.',
  ),
  (Icons.grid_view_rounded, 'Jejak masak', 'Setiap resep yang selesai dimasak mengisi kotak hari itu. Lihat rentetan hari memasak Anda di beranda.'),
  (
    Icons.eco_rounded,
    'Gizi Seimbang',
    'Hitung IMT, berat badan ideal, dan batas gula, garam, serta lemak harian, lalu ikuti rencana makan dari resep yang lebih ringan.',
  ),
  (Icons.menu_book_rounded, 'Buku resep', 'Ratusan resep bisa dicari menurut nama atau bahan, dengan saringan sehat, cepat, sarapan, dan lainnya.'),
];

Future<void> showTour(BuildContext context) => Navigator.of(context).push(
  PageRouteBuilder(
    opaque: false,
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => Scope(state: Scope.of(context), child: const TourScreen()),
    transitionsBuilder: (_, a, _, child) => FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  ),
);

class TourScreen extends StatefulWidget {
  const TourScreen({super.key});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  final _pager = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await Scope.of(context).setPref('tour_done', true);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 8, 0),
                child: TextButton(onPressed: _finish, child: const Text('Lewati')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (icon, title, body) = _pages[i];
                  return AnimatedBuilder(
                    animation: _pager,
                    builder: (_, child) {
                      // halaman yang sedang digeser sedikit mengecil dan memudar
                      final d = _pager.hasClients && _pager.position.haveDimensions ? (_pager.page! - i).abs().clamp(0.0, 1.0) : (i == 0 ? 0.0 : 1.0);
                      return Opacity(
                        opacity: 1 - d * .6,
                        child: Transform.scale(scale: 1 - d * .08, child: child),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            key: ValueKey(i),
                            tween: Tween(begin: .6, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            builder: (_, v, child) => Transform.scale(scale: v, child: child),
                            child: Container(
                              width: 132,
                              height: 132,
                              decoration: const BoxDecoration(color: C.accentTint, shape: BoxShape.circle),
                              child: Icon(icon, size: 60, color: C.accentDeep),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            title,
                            style: poppins(24, weight: FontWeight.w600, height: 1.2),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            body,
                            style: T.callout.copyWith(color: C.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(color: i == _page ? C.accent : C.separator, borderRadius: BorderRadius.circular(4)),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: Pressable(
                  child: FilledButton(
                    onPressed: last ? _finish : () => _pager.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(last ? 'Mulai' : 'Lanjut', key: ValueKey(last)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
