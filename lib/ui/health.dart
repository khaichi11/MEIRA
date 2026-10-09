import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/body.dart';
import '../core/health.dart';
import '../theme.dart';
import 'chat.dart';
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
        title: const Text(programName),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: [
          const FadeIn(child: BodyCard()),
          const SizedBox(height: 18),
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
                child: _Stat(value: '$healthyWeek', label: 'tergolong\nsehat'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(value: '${s.streak}', label: 'hari\nberturut-turut'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Tanya MEIRA soal gizi', style: T.sectionHeader),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in const [
                'Mi instan masih cocok untuk saya?',
                'Berapa kalori nasi goreng?',
                'Camilan apa yang lebih ringan?',
                'Berapa batas gula sehari?',
              ])
                ActionChip(
                  label: Text(q),
                  labelStyle: inter(13.5, color: C.accentDeep, weight: FontWeight.w500),
                  backgroundColor: C.surface,
                  side: const BorderSide(color: C.separator),
                  shape: const StadiumBorder(),
                  onPressed: () {
                    if (s.busy) return;
                    s.newConversation();
                    openChat(context, s);
                    s.send(text: q);
                  },
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

/// Kalkulator tubuh: IMT dengan skala berwarna, rentang berat badan ideal, dan kebutuhan gizi harian. Data hanya
/// disimpan di ponsel.
class BodyCard extends StatelessWidget {
  const BodyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final n = s.needs;
    if (n == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_weight_outlined, color: C.accentDeep),
                const SizedBox(width: 10),
                Expanded(child: Text('Kalkulator tubuh ideal', style: T.headline)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Isi tinggi, berat, usia, dan aktivitas untuk melihat IMT, berat badan ideal, serta batas gula, garam, dan lemak harian Anda.',
              style: T.subhead,
            ),
            const SizedBox(height: 12),
            Pressable(
              child: FilledButton.icon(
                onPressed: () => showBodyForm(context),
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Isi data tubuh'),
              ),
            ),
          ],
        ),
      );
    }
    final b = s.body!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Tubuh Anda', style: T.headline)),
              TextButton(onPressed: () => showBodyForm(context), child: const Text('Ubah')),
            ],
          ),
          Text('${b.heightCm.round()} cm, ${_kg(b.weightKg)} kg, ${b.age} tahun', style: T.footnote),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: n.bmi),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Text(
                  v.toStringAsFixed(1).replaceAll('.', ','),
                  style: poppins(32, weight: FontWeight.w700, color: C.label),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'IMT  ·  ${n.category}',
                  style: inter(14, weight: FontWeight.w600, color: C.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BmiScale(bmi: n.bmi),
          const SizedBox(height: 14),
          Text(
            'Berat badan ideal untuk tinggi Anda ${_kg(n.idealMin)} sampai ${_kg(n.idealMax)} kg (IMT 18,5 sampai 25), '
            'dan menurut rumus Broca sekitar ${_kg(n.broca)} kg.',
            style: T.subhead,
          ),
          const SizedBox(height: 14),
          Text('Kebutuhan harian (perkiraan)', style: T.sectionHeader),
          const SizedBox(height: 8),
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
                child: _Need(label: 'Karbohidrat', value: '${n.carbs}', unit: 'g', color: C.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Batas harian', style: T.sectionHeader),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Need(label: 'Gula', value: '${n.sugar}', unit: 'g', color: C.violet),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Lemak', value: '${n.fat}', unit: 'g', color: C.clay),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Need(label: 'Garam', value: '${n.salt}', unit: 'g', color: C.secondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Perkiraan untuk orang dewasa sehat (Mifflin-St Jeor, Pedoman Gizi Seimbang, Permenkes No. 30 Tahun 2013). '
            'MEIRA memakai angka ini saat Anda bertanya apakah suatu makanan cocok.',
            style: T.caption,
          ),
        ],
      ),
    );
  }

  static String _kg(double v) => v.toStringAsFixed(1).replaceAll('.', ',').replaceAll(',0', '');
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
  late final _w = TextEditingController(text: s.body == null ? '' : BodyCard._kg(s.body!.weightKg));
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
