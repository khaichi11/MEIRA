import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

void openInfo(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoScreen()));

/// Sumber data, rumus, dan catatan penggunaan. Layar fitur cukup menampilkan ringkasan; penjelasan lengkapnya di sini.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _groups = [
    (
      'Data makanan',
      Icons.restaurant_menu_rounded,
      C.accent,
      [
        ('Buku resep dan catatan dapur', 'Ditulis untuk MEIRA, domain publik (CC0).'),
        ('Fakta makanan', 'Wikidata (CC0): nama, deskripsi, bahan, dan asal.'),
        ('Kandungan gizi', 'USDA FoodData Central SR Legacy (domain publik), per 100 gram.'),
      ],
    ),
    (
      'Perhitungan tubuh',
      Icons.monitor_weight_outlined,
      C.violet,
      [
        ('IMT', 'Berat (kg) dibagi kuadrat tinggi (m). Kategori Kementerian Kesehatan RI.'),
        ('Berat badan ideal', 'IMT 18,5 sampai 25, dan rumus Broca.'),
        ('Kebutuhan energi', 'Mifflin-St Jeor dikali faktor aktivitas.'),
        ('Pembagian gizi', 'Pedoman Gizi Seimbang: protein 15%, lemak 25%, karbohidrat 60%.'),
        ('Batas gula, garam, lemak', 'Permenkes No. 30 Tahun 2013: 50 g, 5 g, dan 67 g sehari.'),
      ],
    ),
    (
      'Jendela makan',
      Icons.schedule_rounded,
      C.blue,
      [
        ('Pola', 'Pembatasan waktu makan (time-restricted eating); hanya pengatur jadwal, bukan anjuran medis.'),
        ('Tidak disarankan', 'Untuk ibu hamil atau menyusui, penderita diabetes, gangguan makan, dan anak.'),
      ],
    ),
    (
      'Privasi',
      Icons.lock_outline_rounded,
      C.herb,
      [
        ('Penyimpanan', 'Data tubuh, catatan makan, dan berat hanya disimpan di ponsel ini.'),
        ('Kesehatan', 'Angka di MEIRA adalah perkiraan. Untuk kondisi medis, konsultasikan dengan dokter atau ahli gizi.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      title: const Text('Sumber data dan rumus'),
    ),
    body: ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        for (final (gi, (title, icon, color, rows)) in _groups.indexed)
          FadeIn(
            delay: Duration(milliseconds: 60 * gi),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, size: 19, color: color),
                      ),
                      const SizedBox(width: 10),
                      Text(title, style: T.headline),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final (k, v) in rows)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k, style: inter(14, weight: FontWeight.w600)),
                          Text(v, style: T.footnote),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
