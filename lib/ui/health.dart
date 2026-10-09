import 'package:flutter/material.dart';

import '../core/health.dart';
import '../theme.dart';
import 'recipe_book.dart';
import 'widgets.dart';

/// Tujuan program hidup sehat. Kata-katanya netral dan sopan; istilah medis seperti obesitas hanya dipakai sebagai
/// keterangan, tidak pernah sebagai sebutan untuk pengguna.
const healthGoals = [
  ('turun', 'Menurunkan berat badan bertahap', 'Untuk berat badan berlebih atau obesitas: perbanyak sayur, kurangi gorengan dan gula.'),
  ('jaga', 'Menjaga berat badan', 'Porsi seimbang dan resep ringan untuk sehari-hari.'),
  ('seimbang', 'Makan lebih seimbang', 'Lebih banyak sayur, buah, dan lauk rendah lemak.'),
];

String goalTitle(String? key) => healthGoals.firstWhere((g) => g.$1 == key, orElse: () => healthGoals.last).$2;

void openHealth(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthScreen()));

/// Pilihan rasa: "Enak" mendahulukan kecocokan bahan, "Enak dan sehat" juga mendahulukan resep yang lebih ringan dan
/// menambah satu saran agar resep lebih ringan.
class TasteToggle extends StatelessWidget {
  const TasteToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Enak')),
        ButtonSegment(value: true, label: Text('Enak & sehat')),
      ],
      selected: {s.healthyMode},
      showSelectedIcon: false,
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(inter(14, weight: FontWeight.w600)),
        backgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? C.accentTint : C.surface),
        foregroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? C.accentDeep : C.secondary),
        side: const WidgetStatePropertyAll(BorderSide(color: C.separator)),
      ),
      onSelectionChanged: (v) => s.setPref('healthy_mode', v.first),
    );
  }
}

/// Rencana makan hari ini: empat baris resep sehat yang bisa diganti satu per satu.
class DailyPlan extends StatefulWidget {
  const DailyPlan({super.key, this.compact = false});
  final bool compact;

  @override
  State<DailyPlan> createState() => _DailyPlanState();
}

class _DailyPlanState extends State<DailyPlan> {
  final Map<String, int> _shift = {};

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final plan = dailyPlan(s.recipes, DateTime.now(), shift: _shift);
    return Column(
      children: [
        for (final (i, (slot, r)) in plan.indexed)
          FadeIn(
            key: ValueKey('$slot/${r.id}'),
            delay: Duration(milliseconds: 60 * i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: RecipeRow(recipe: r, label: slot),
                  ),
                  if (!widget.compact)
                    IconButton(
                      tooltip: 'Ganti',
                      icon: const Icon(Icons.refresh_rounded, color: C.secondary),
                      onPressed: () => setState(() => _shift.update(slot, (v) => v + 1, ifAbsent: () => 1)),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Program hidup sehat: tujuan, rencana makan hari ini, capaian pekan ini, dan pedoman umum Kementerian Kesehatan.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final (week, healthyWeek) = s.cookedThisWeek;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Hidup sehat'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: [
          Text('Tujuan', style: T.sectionHeader),
          const SizedBox(height: 8),
          for (final (i, (key, title, sub)) in healthGoals.indexed)
            FadeIn(
              delay: Duration(milliseconds: 50 * i),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Pressable(
                  child: Material(
                    color: s.healthGoal == key ? C.accentTint : C.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await s.setPref('health_goal', key);
                        if (!s.healthyMode) await s.setPref('healthy_mode', true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              s.healthGoal == key ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: s.healthGoal == key ? C.accentDeep : C.tertiary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: T.headline),
                                  const SizedBox(height: 2),
                                  Text(sub, style: T.footnote),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Rencana hari ini', style: T.sectionHeader),
          const SizedBox(height: 8),
          const DailyPlan(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Stat(value: '$week', label: 'masakan\n7 hari terakhir'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(value: '$healthyWeek', label: 'di antaranya\ntergolong sehat'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(value: '${s.streak}', label: 'hari memasak\nberturut-turut'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Pedoman umum', style: T.sectionHeader),
          const SizedBox(height: 8),
          const _Guide(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Isi Piringku',
            body: 'Separuh piring berisi sayur dan buah, seperempat makanan pokok, dan seperempat lauk. Minum air putih yang cukup.',
          ),
          const _Guide(
            icon: Icons.water_drop_outlined,
            title: 'Batas gula, garam, dan lemak sehari',
            body: 'Gula paling banyak 50 gram (4 sendok makan), garam 5 gram (1 sendok teh), dan lemak 67 gram (5 sendok makan minyak).',
          ),
          const _Guide(
            icon: Icons.local_fire_department_outlined,
            title: 'Cara memasak',
            body: 'Kukus, rebus, panggang, atau tumis dengan sedikit minyak lebih ringan daripada menggoreng dalam minyak banyak.',
          ),
          const SizedBox(height: 8),
          Text(
            'Sumber: Kementerian Kesehatan RI (Isi Piringku; Permenkes No. 30 Tahun 2013). Untuk obesitas, diabetes, hipertensi, '
            'atau kondisi medis lain, rencana makan sebaiknya disusun bersama dokter atau ahli gizi.',
            style: T.caption,
          ),
          if (s.healthGoal != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: () => s.setPref('health_goal', ''), child: const Text('Hentikan program')),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.separator),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: double.tryParse(value) ?? 0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Text(
            '${v.round()}',
            style: poppins(24, weight: FontWeight.w700, color: C.accentDeep),
          ),
        ),
        Text(label, style: T.caption),
      ],
    ),
  );
}

class _Guide extends StatelessWidget {
  const _Guide({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: C.herb),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.headline),
                const SizedBox(height: 4),
                Text(body, style: T.subhead),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
