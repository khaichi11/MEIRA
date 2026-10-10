import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../core/body.dart';
import '../core/fasting.dart';
import '../core/health.dart';
import '../core/intake.dart';
import '../core/tools.dart';
import '../theme.dart';
import 'chat.dart';
import 'info.dart';
import 'recipe_book.dart';
import 'widgets.dart';

/// Tujuan program hidup sehat. Kata-katanya netral dan sopan; istilah medis seperti obesitas hanya dipakai sebagai
/// keterangan, tidak pernah sebagai sebutan untuk pengguna.
const healthGoals = [
  ('turun', 'Menuju berat badan ideal', 'Perbanyak sayur, kurangi gorengan dan gula, dan turunkan berat badan secara bertahap.'),
  ('jaga', 'Menjaga berat badan', 'Porsi seimbang dan resep ringan untuk sehari-hari.'),
  ('seimbang', 'Makan lebih seimbang', 'Lebih banyak sayur, buah, dan lauk rendah lemak.'),
];

/// Nama program yang tampil di beranda dan judul layar; memakai istilah Kementerian Kesehatan, bukan sebutan tentang
/// bentuk tubuh.
const programName = 'Gizi Seimbang';

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
      onSelectionChanged: (v) {
        s.setPref('healthy_mode', v.first);
        // pengaruhnya baru terlihat pada rekomendasi berikutnya, jadi langsung dijelaskan
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                v.first
                    ? 'Rekomendasi berikutnya mendahulukan resep yang tidak digoreng, tidak bersantan kental, dan tidak banyak gula.'
                    : 'Rekomendasi berikutnya hanya mengikuti bahan yang Anda punya.',
              ),
            ),
          );
      },
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

/// Gizi Seimbang: ringkasan hari ini, catatan makan, tubuh dan progres berat, puasa berselang, rencana makan, dan
/// tujuan. Setiap kartu hanya ringkasan; sumber data dan rumus ada di layar info.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final cards = <Widget>[
      const TodayCard(),
      const MealsCard(),
      const BodyCard(),
      const WeightCard(),
      const FastingCard(),
      _Card(title: 'Rencana hari ini', icon: Icons.restaurant_menu_rounded, color: C.herb, child: const DailyPlan()),
      _Card(
        title: 'Tujuan',
        icon: Icons.flag_outlined,
        color: C.violet,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, title, _) in healthGoals)
              ChoiceChip(
                label: Text(title),
                selected: s.healthGoal == key,
                showCheckmark: false,
                labelStyle: inter(13.5, weight: FontWeight.w600, color: s.healthGoal == key ? Colors.white : C.label),
                selectedColor: C.violet,
                backgroundColor: C.surface,
                side: BorderSide(color: s.healthGoal == key ? C.violet : C.separator),
                shape: const StadiumBorder(),
                onSelected: (_) async {
                  await s.setPref('health_goal', s.healthGoal == key ? '' : key);
                  if (!s.healthyMode && s.healthGoal != null) await s.setPref('healthy_mode', true);
                },
              ),
          ],
        ),
      ),
      _Card(
        title: 'Tanya MEIRA',
        icon: Icons.forum_outlined,
        color: C.accent,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final q in const ['Mi instan masih cocok untuk saya?', 'Makanan saya hari ini masih aman?', 'Kapan saya boleh makan?'])
              ActionChip(
                label: Text(q),
                labelStyle: inter(13.5, color: C.accentDeep, weight: FontWeight.w500),
                backgroundColor: C.accentTint,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                onPressed: () {
                  if (s.busy) return;
                  s.newConversation();
                  s.setChatMode('gizi');
                  openChat(context, s);
                  s.send(text: q);
                },
              ),
          ],
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text(programName),
        actions: [IconButton(tooltip: 'Sumber data dan rumus', icon: const Icon(Icons.info_outline_rounded), onPressed: () => openInfo(context))],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: [
          for (final (i, c) in cards.indexed)
            FadeIn(
              delay: Duration(milliseconds: 50 * i),
              child: Padding(padding: const EdgeInsets.only(bottom: 14), child: c),
            ),
        ],
      ),
    );
  }
}

/// Kartu dasar layar Gizi Seimbang: ikon berwarna, judul, tombol di kanan, dan isi.
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.color, required this.child, this.action});
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
    decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(22)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: T.headline)),
            ?action,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// Batang kemajuan satu zat gizi: hijau aman, kuning mendekati batas, merah melewati batas.
class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.value, required this.target, required this.unit, this.limit = true});
  final String label, unit;
  final double value, target;
  final bool limit; // batas (gula, lemak, garam) atau kebutuhan (energi, protein)

  @override
  Widget build(BuildContext context) {
    final level = limit ? levelOf(value, target) : Level.safe;
    final color = switch (level) {
      Level.safe => limit ? C.herb : C.accent,
      Level.near => const Color(0xFFE0A100),
      Level.over => C.clay,
    };
    final f = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(label, style: inter(13, color: C.secondary)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  Container(height: 9, color: C.grouped),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: f),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => FractionallySizedBox(
                      widthFactor: v,
                      child: Container(height: 9, color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 86,
            child: Text(
              '${value.round()}/${target.round()} $unit',
              textAlign: TextAlign.right,
              style: inter(12.5, weight: FontWeight.w600, color: level == Level.over ? C.clay : C.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan hari ini: asupan dari catatan makan dibandingkan kebutuhan dan batas harian.
class TodayCard extends StatelessWidget {
  const TodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final t = Targets.of(s.needs);
    final today = s.intakeToday;
    final total = today.fold(const Nutrients(), (a, e) => a + e.nutrients);
    final over =
        [levelOf(total.sugar, t.sugar), levelOf(total.fat, t.fat), levelOf(total.salt, t.salt)].contains(Level.over) || total.energy > t.energy;
    // hari tanpa catatan tidak disebut "aman": angkanya nol karena belum dicatat, bukan karena pilihannya baik
    final (badge, tone) = today.isEmpty ? ('Belum dicatat', C.secondary) : (over ? ('Ada yang lewat batas', C.clay) : ('Masih aman', C.herb));
    return _Card(
      title: 'Hari ini',
      icon: Icons.today_rounded,
      color: over ? C.clay : C.accent,
      action: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: tone.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
        child: Text(
          badge,
          style: inter(12.5, weight: FontWeight.w600, color: tone),
        ),
      ),
      child: Column(
        children: [
          if (today.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Tambahkan makanan di bawah, atau ketik "tadi pagi saya makan roti" di obrolan.', style: T.footnote),
            ),
          _Meter(label: 'Energi', value: total.energy, target: t.energy, unit: 'kkal', limit: total.energy > t.energy),
          _Meter(label: 'Protein', value: total.protein, target: t.protein, unit: 'g', limit: false),
          _Meter(label: 'Gula', value: total.sugar, target: t.sugar, unit: 'g'),
          _Meter(label: 'Lemak', value: total.fat, target: t.fat, unit: 'g'),
          _Meter(label: 'Garam', value: total.salt, target: t.salt, unit: 'g'),
          if (!t.personal)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: () => showBodyForm(context), child: const Text('Pakai angka sesuai tubuh Anda')),
            ),
        ],
      ),
    );
  }
}

/// Catatan makan hari ini per waktu makan; tambah lewat tombol atau lewat obrolan ("tadi pagi saya makan ...").
class MealsCard extends StatelessWidget {
  const MealsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final today = s.intakeToday;
    return _Card(
      title: 'Makan hari ini',
      icon: Icons.ramen_dining_outlined,
      color: const Color(0xFFE0A100),
      child: Column(
        children: [
          for (final slot in mealSlots) ...[
            Row(
              children: [
                Expanded(
                  child: Text(slot, style: inter(13.5, weight: FontWeight.w600)),
                ),
                IconButton(
                  tooltip: 'Tambah untuk ${slot.toLowerCase()}',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline_rounded, color: C.accent),
                  onPressed: () => showAddFood(context, slot),
                ),
              ],
            ),
            for (final e in today.where((e) => e.slot == slot))
              Dismissible(
                key: ObjectKey(e),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  s.removeIntake(e);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${e.food} dihapus'),
                        action: SnackBarAction(label: 'Urungkan', onPressed: () => s.logIntake(e)),
                      ),
                    );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  child: const Icon(Icons.delete_outline_rounded, color: C.clay),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 6, right: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: C.tertiary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${e.food}  ·  ${e.grams.round()} g', style: T.callout)),
                      Text('${e.nutrients.energy.round()} kkal', style: T.footnote),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Lembar tambah makanan: cari makanan, pilih jumlah porsi, lalu simpan.
Future<void> showAddFood(BuildContext context, String slot) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: C.bg,
  builder: (_) => Scope(
    state: Scope.of(context),
    child: _AddFood(slot: slot),
  ),
);

class _AddFood extends StatefulWidget {
  const _AddFood({required this.slot});
  final String slot;

  @override
  State<_AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<_AddFood> {
  final _q = TextEditingController();
  Food? _food;
  double _count = 1;

  @override
  void initState() {
    super.initState();
    _q.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final q = _q.text.trim().toLowerCase();
    final list = s.foods.where((f) => q.isEmpty || f.names.any((n) => n.toLowerCase().contains(q))).take(40).toList();
    final f = _food;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.viewPaddingOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.slot, style: T.title),
            const SizedBox(height: 12),
            if (f == null) ...[
              TextField(
                controller: _q,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                style: T.body,
                decoration: InputDecoration(
                  hintText: 'Cari makanan, misalnya nasi atau mi instan',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: C.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final food in list)
                      ListTile(
                        title: Text(food.name, style: T.callout),
                        subtitle: Text('${food.per100.energy.round()} kkal per 100 g', style: T.footnote),
                        trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
                        onTap: () => setState(() => _food = food),
                      ),
                  ],
                ),
              ),
            ] else ...[
              Text(f.name, style: T.headline),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton.filledTonal(onPressed: _count > .5 ? () => setState(() => _count -= .5) : null, icon: const Icon(Icons.remove_rounded)),
                  Expanded(
                    child: Text(
                      '${fmt(_count)} ${f.portion.$2}\n${(f.portion.$1 * _count).round()} g, '
                      '${(f.per100.energy * f.portion.$1 * _count / 100).round()} kkal',
                      textAlign: TextAlign.center,
                      style: T.callout,
                    ),
                  ),
                  IconButton.filledTonal(onPressed: () => setState(() => _count += .5), icon: const Icon(Icons.add_rounded)),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  final grams = f.portion.$1 * _count;
                  await s.logIntake(IntakeEntry(DateTime.now(), widget.slot, f.name, grams, f.per100.scale(grams / 100)));
                  HapticFeedback.lightImpact();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
              TextButton(onPressed: () => setState(() => _food = null), child: const Text('Pilih makanan lain')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tubuh: IMT dengan skala, berat sekarang, rentang ideal, dan kebutuhan harian dalam petak berwarna.
class BodyCard extends StatelessWidget {
  const BodyCard({super.key});

  static String kg(double v) => fmt(v);

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final n = s.needs;
    if (n == null) {
      return _Card(
        title: 'Kalkulator tubuh',
        icon: Icons.monitor_weight_outlined,
        color: C.violet,
        child: Pressable(
          child: FilledButton.icon(
            onPressed: () => showBodyForm(context),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Isi tinggi dan berat'),
          ),
        ),
      );
    }
    return _Card(
      title: 'Tubuh',
      icon: Icons.monitor_weight_outlined,
      color: C.violet,
      action: TextButton(onPressed: () => showBodyForm(context), child: const Text('Ubah')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: n.bmi),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Text(
                  fmt(v),
                  style: poppins(30, weight: FontWeight.w700, color: C.label),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'IMT  ·  ${n.category}',
                  style: inter(13.5, weight: FontWeight.w600, color: C.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BmiScale(bmi: n.bmi),
          const SizedBox(height: 6),
          Text('Ideal ${kg(n.idealMin)} sampai ${kg(n.idealMax)} kg  ·  sekarang ${kg(s.body!.weightKg)} kg', style: T.footnote),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Need(label: 'Energi', value: '${n.energy}', unit: 'kkal', color: C.accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Protein', value: '${n.protein}', unit: 'g', color: C.herb),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Karbo', value: '${n.carbs}', unit: 'g', color: C.blue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Need(label: 'Gula maks', value: '${n.sugar}', unit: 'g', color: C.violet),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Lemak maks', value: '${n.fat}', unit: 'g', color: C.clay),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Garam maks', value: '${n.salt}', unit: 'g', color: C.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progres berat: grafik garis dari catatan berat dengan pita rentang ideal, dan tombol catat berat.
class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final w = s.weights;
    final change = w.length < 2 ? null : w.last.$2 - w.first.$2;
    return _Card(
      title: 'Progres berat',
      icon: Icons.show_chart_rounded,
      color: C.blue,
      action: TextButton(onPressed: () => _logWeight(context), child: const Text('Catat')),
      child: w.isEmpty
          ? Text('Belum ada catatan. Ketuk Catat, atau ketik "berat saya 70 kg" di obrolan.', style: T.footnote)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${fmt(w.last.$2)} kg', style: poppins(24, weight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    if (change != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${change <= 0 ? '−' : '+'}${fmt(change.abs())} kg sejak awal',
                          style: inter(13, weight: FontWeight.w600, color: change <= 0 ? C.herb : C.secondary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: WeightChart(points: w, idealMin: s.needs?.idealMin, idealMax: s.needs?.idealMax),
                ),
              ],
            ),
    );
  }

  static Future<void> _logWeight(BuildContext context) async {
    final s = Scope.of(context);
    final c = TextEditingController(text: s.weights.isEmpty ? '' : fmt(s.weights.last.$2));
    final kg = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.bg,
        title: Text('Berat hari ini', style: T.headline),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, double.tryParse(c.text.trim().replaceAll(',', '.'))), child: const Text('Simpan')),
        ],
      ),
    );
    c.dispose();
    if (kg == null || kg < 25 || kg > 300) return;
    HapticFeedback.lightImpact();
    await s.logWeight(kg);
    final b = s.body;
    if (b != null) await s.setBody(BodyProfile(heightCm: b.heightCm, weightKg: kg, age: b.age, male: b.male, activity: b.activity));
  }
}

/// Grafik garis berat badan; garis tergambar dari kiri ke kanan saat muncul.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.points, this.idealMin, this.idealMax});
  final List<(DateTime, double)> points;
  final double? idealMin, idealMax;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 900),
    curve: Curves.easeOutCubic,
    builder: (_, t, _) => CustomPaint(painter: _ChartPainter(points, idealMin, idealMax, t), size: Size.infinite),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.points, this.idealMin, this.idealMax, this.t);
  final List<(DateTime, double)> points;
  final double? idealMin, idealMax;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final values = [for (final (_, w) in points) w, ?idealMax, ?idealMin];
    var lo = values.reduce((a, b) => a < b ? a : b) - 1, hi = values.reduce((a, b) => a > b ? a : b) + 1;
    if (hi - lo < 4) {
      lo -= 2;
      hi += 2;
    }
    double y(double v) => size.height - (v - lo) / (hi - lo) * size.height;
    if (idealMin != null && idealMax != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(0, y(idealMax!), size.width, y(idealMin!)), const Radius.circular(6)),
        Paint()..color = C.herb.withValues(alpha: .10),
      );
      // keterangan pita supaya tidak terbaca sebagai kotak kosong
      final label = TextPainter(
        text: TextSpan(
          text: 'Rentang ideal ${fmt(idealMin!)}–${fmt(idealMax!)} kg',
          style: inter(11, weight: FontWeight.w600, color: C.herb),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - 16);
      final top = y(idealMax!), bottom = y(idealMin!);
      if (bottom - top >= label.height + 4) label.paint(canvas, Offset(8, top + (bottom - top - label.height) / 2));
    }
    if (points.length == 1) {
      canvas.drawCircle(Offset(size.width / 2, y(points.first.$2)), 4.5, Paint()..color = C.blue);
      return;
    }
    final t0 = points.first.$1, span = points.last.$1.difference(t0).inMinutes.clamp(1, 1 << 31);
    final pts = [for (final (d, w) in points) Offset(d.difference(t0).inMinutes / span * size.width, y(w))];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final metric = path.computeMetrics().first;
    // bidang lembut di bawah garis, ikut tergambar dari kiri
    final reach = size.width * t;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, reach, size.height));
    canvas.drawPath(
      Path.from(path)
        ..lineTo(pts.last.dx, size.height)
        ..lineTo(pts.first.dx, size.height)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.blue.withValues(alpha: .18), C.blue.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
    canvas.drawPath(
      metric.extractPath(0, metric.length * t),
      Paint()
        ..color = C.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in pts) {
      if (p.dx <= size.width * t + 1) canvas.drawCircle(p, 3.5, Paint()..color = C.blue);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.t != t || old.points != points;
}

/// Jendela makan: pilih pola dan jam dibuka; lingkaran menunjukkan kemajuan tahap saat ini.
class FastingCard extends StatefulWidget {
  const FastingCard({super.key});

  @override
  State<FastingCard> createState() => _FastingCardState();
}

class _FastingCardState extends State<FastingCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _set(AppState s, FastingPlan? p) async {
    final ok = await s.setFasting(p);
    if (!ok && mounted) toast(context, 'Izin notifikasi ditolak, jadwal tetap tersimpan tanpa pengingat');
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final f = s.fasting;
    final now = DateTime.now();
    final st = f == null ? null : fastingState(f, now);
    return _Card(
      title: 'Jendela makan',
      icon: Icons.schedule_rounded,
      color: C.blue,
      action: f == null ? null : TextButton(onPressed: () => _set(s, null), child: const Text('Matikan')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (st != null)
            Row(
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: st.progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 7,
                      backgroundColor: C.grouped,
                      color: st.eating ? C.herb : C.blue,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(st.eating ? 'Jendela makan terbuka' : 'Di luar jendela makan', style: T.headline),
                      Text(
                        st.eating
                            ? 'Ditutup pukul ${clock(f!.endMinute)}, ${untilText(st.next, now)} lagi'
                            : 'Dibuka pukul ${clock(f!.startMinute)}, ${untilText(st.next, now)} lagi',
                        style: T.footnote,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (st != null) const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in FastingPlan.options)
                ChoiceChip(
                  label: Text('$h:${24 - h}'),
                  selected: f?.fastHours == h,
                  showCheckmark: false,
                  labelStyle: inter(13.5, weight: FontWeight.w600, color: f?.fastHours == h ? Colors.white : C.label),
                  selectedColor: C.blue,
                  backgroundColor: C.surface,
                  side: BorderSide(color: f?.fastHours == h ? C.blue : C.separator),
                  shape: const StadiumBorder(),
                  onSelected: (_) => _set(s, FastingPlan(h, f?.startMinute ?? 12 * 60)),
                ),
              ActionChip(
                avatar: const Icon(Icons.access_time_rounded, size: 18),
                label: Text('Dibuka ${clock(f?.startMinute ?? 12 * 60)}'),
                backgroundColor: C.surface,
                side: const BorderSide(color: C.separator),
                shape: const StadiumBorder(),
                onPressed: () async {
                  final start = f?.startMinute ?? 12 * 60;
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: start ~/ 60, minute: start % 60),
                  );
                  if (picked != null) await _set(s, FastingPlan(f?.fastHours ?? 16, picked.hour * 60 + picked.minute));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _tone(double bmi) => bmi < 18.5
    ? C.blue
    : bmi <= 25
    ? C.herb
    : bmi <= 27
    ? const Color(0xFFE0A100)
    : C.clay;

/// Skala IMT 15 sampai 35 dengan empat warna dan penanda yang bergeser ke posisi pengguna.
class BmiScale extends StatelessWidget {
  const BmiScale({super.key, required this.bmi});
  final double bmi;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      double x(double v) => ((v - 15) / 20).clamp(0.0, 1.0) * box.maxWidth;
      const bands = [(15.0, 18.5, C.blue), (18.5, 25.0, C.herb), (25.0, 27.0, Color(0xFFE0A100)), (27.0, 35.0, C.clay)];
      return SizedBox(
        height: 30,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 10,
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    for (final (a, b, c) in bands)
                      SizedBox(
                        width: x(b) - x(a),
                        height: 8,
                        child: ColoredBox(color: c.withValues(alpha: .75)),
                      ),
                  ],
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 15, end: bmi),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (_, v, _) => Positioned(
                left: x(v) - 9,
                top: 5,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _tone(bmi), width: 3),
                    boxShadow: [BoxShadow(color: C.label.withValues(alpha: .15), blurRadius: 6)],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Need extends StatelessWidget {
  const _Need({required this.label, required this.value, required this.unit, required this.color});
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: inter(12, color: C.secondary)),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value,
                style: poppins(19, weight: FontWeight.w700, color: color),
              ),
              TextSpan(
                text: ' $unit',
                style: inter(12, color: C.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Lembar isian data tubuh.
Future<void> showBodyForm(BuildContext context) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: C.bg,
  builder: (_) => Scope(state: Scope.of(context), child: const _BodyForm()),
);

class _BodyForm extends StatefulWidget {
  const _BodyForm();

  @override
  State<_BodyForm> createState() => _BodyFormState();
}

class _BodyFormState extends State<_BodyForm> {
  late final AppState s = Scope.of(context);
  late final _h = TextEditingController(text: s.body?.heightCm.round().toString() ?? '');
  late final _w = TextEditingController(text: s.body == null ? '' : BodyCard.kg(s.body!.weightKg));
  late final _a = TextEditingController(text: s.body?.age.toString() ?? '');
  late bool _male = s.body?.male ?? false;
  late String _act = s.body?.activity ?? 'ringan';
  String? _error;

  @override
  void dispose() {
    _h.dispose();
    _w.dispose();
    _a.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    final h = _num(_h), w = _num(_w), a = _num(_a);
    if (h == null || h < 100 || h > 230 || w == null || w < 25 || w > 300 || a == null || a < 18 || a > 100) {
      setState(() => _error = 'Periksa lagi: tinggi 100 sampai 230 cm, berat 25 sampai 300 kg, usia 18 sampai 100 tahun.');
      return;
    }
    await s.setBody(BodyProfile(heightCm: h, weightKg: w, age: a.round(), male: _male, activity: _act));
    if (mounted) Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController c, String suffix) => Expanded(
    child: TextField(
      controller: c,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: T.body,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: C.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.viewPaddingOf(context).bottom),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Data tubuh', style: T.title),
          const SizedBox(height: 4),
          Text('Hanya disimpan di ponsel ini.', style: T.footnote),
          const SizedBox(height: 16),
          Row(children: [_field('Tinggi', _h, 'cm'), const SizedBox(width: 10), _field('Berat', _w, 'kg')]),
          const SizedBox(height: 10),
          Row(
            children: [
              _field('Usia', _a, 'tahun'),
              const SizedBox(width: 10),
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Perempuan')),
                    ButtonSegment(value: true, label: Text('Laki-laki')),
                  ],
                  selected: {_male},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => setState(() => _male = v.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Aktivitas', style: T.sectionHeader),
          const SizedBox(height: 6),
          RadioGroup<String>(
            groupValue: _act,
            onChanged: (v) => setState(() => _act = v ?? _act),
            child: Column(
              children: [
                for (final MapEntry(key: k, value: (title, sub, _)) in BodyProfile.activities.entries)
                  RadioListTile<String>(
                    value: k,
                    title: Text(title, style: T.callout),
                    subtitle: Text(sub, style: T.footnote),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_error!, style: inter(13, color: C.clay)),
            ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Hitung')),
          if (s.body != null)
            TextButton(
              onPressed: () async {
                await s.setBody(null);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Hapus data tubuh'),
            ),
        ],
      ),
    ),
  );
}
