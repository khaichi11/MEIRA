import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/body.dart';
import 'package:meira/core/fasting.dart';
import 'package:meira/core/intake.dart';
import 'package:meira/core/label.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/core/tools.dart';
import 'package:meira/vision/ocr.dart';

/// Data palsu untuk menguji perintah fitur di obrolan tanpa aplikasi.
class FakeData implements AppData {
  @override
  String? userName;
  @override
  Future<void> setName(String name) async => userName = name;
  @override
  BodyProfile? body;
  @override
  String? healthGoal;
  @override
  FastingPlan? fasting;
  @override
  final List<(DateTime, double)> weights = [];
  final List<IntakeEntry> eaten = [];
  @override
  DailyNeeds? get needs => body == null ? null : needsFor(body!, goal: healthGoal);
  @override
  int get streak => 2;
  @override
  int get bestStreak => 5;
  @override
  int get cookedTotal => 9;
  @override
  List<Recipe> get recipes => const [];
  @override
  List<Food> get foods => [
    Food('mi instan', const ['mi instan'], const Nutrients(energy: 440, protein: 10.2, fat: 17.6, carbs: 60.3, sugar: 2, sodium: 1855)),
    Food('nasi', const ['nasi'], const Nutrients(energy: 130, protein: 2.7, fat: .3, carbs: 28, sodium: 1)),
  ];
  @override
  List<IntakeEntry> get intakeToday => eaten;
  @override
  Future<void> logWeight(double kg) async => weights.add((DateTime(2026, 10, 1), kg));
  @override
  Future<void> setBody(BodyProfile b) async => body = b;
  @override
  Future<void> logIntake(IntakeEntry e) async => eaten.add(e);
  @override
  Future<void> removeLastIntake() async => eaten.removeLast();
  @override
  Future<bool> setFasting(FastingPlan? p) async {
    fasting = p;
    return true;
  }
}

Future<ToolReply?> run(String text, FakeData d) async {
  final r = appTool(text, d);
  await r?.effect?.call();
  return r;
}

void main() {
  test('data tubuh dari obrolan disimpan dan dijawab dengan angka', () async {
    final d = FakeData();
    final r = await run('tinggi saya 165 cm, berat 80 kg, umur 30, laki-laki', d);
    expect(r!.text, contains('IMT Anda 29,4'));
    expect(d.body!.heightCm, 165);
    expect(d.weights.single.$2, 80);
    expect((await run('berapa imt saya?', d))!.text, contains('29,4'));
    expect((await run('berat badan ideal saya berapa?', d))!.text, contains('50,4 sampai 68,1'));
  });

  test('data tubuh yang belum lengkap meminta sisanya', () async {
    final r = await run('tinggi saya 160 cm', FakeData());
    expect(r!.text, contains('berat badan, usia dan jenis kelamin'));
    expect(r.actions, ['tubuh']);
  });

  test('catat berat dan progres', () async {
    final d = FakeData()..weights.add((DateTime(2026, 9, 1), 82));
    final r = await run('berat saya sekarang 79,5 kg', d);
    expect(r!.text, contains('Turun 2,5 kg sejak 1 September'));
    expect(d.weights.last.$2, 79.5);
    expect((await run('gimana progres berat saya?', d))!.text, contains('79,5 kg'));
  });

  test('catat makan dan ringkasan hari ini', () async {
    final d = FakeData();
    final r = await run('tadi pagi saya makan mi instan 2 bungkus', d);
    expect(r!.text, contains('sarapan: mi instan 2 bungkus'));
    expect(d.eaten.single.grams, 170);
    expect(r.text, contains('Garam sudah melewati batas harian'));
    expect((await run('hari ini saya makan apa saja?', d))!.text, contains('sarapan mi instan'));
    expect(await run('resep mi instan yang enak apa?', d), isNull);
  });

  test('beberapa makanan dalam satu pesan, masing-masing dengan porsinya', () async {
    final d = FakeData();
    final r = await run('tadi siang saya makan nasi 2 piring dan mi instan 1 bungkus', d);
    expect([for (final e in d.eaten) (e.food, e.grams)], [('nasi', 300.0), ('mi instan', 85.0)]);
    expect(r!.text, contains('nasi 2 piring'));
    expect(r.text, contains('mi instan 1 bungkus'));
    // jumlah sebelum nama, bentuk "se-", dan jumlah yang diapit dua makanan
    expect(
      [for (final (f, g, _) in parseMeal('2 piring nasi dan sebungkus mi instan', d.foods)) (f.name, g)],
      [('nasi', 300.0), ('mi instan', 85.0)],
    );
    expect([for (final (f, g, _) in parseMeal('nasi 1 piring mi instan 2 bungkus', d.foods)) (f.name, g)], [('nasi', 150.0), ('mi instan', 170.0)]);
    expect([for (final (_, g, _) in parseMeal('mi instan 1,5 bungkus', d.foods)) g], [127.5]);
  });

  test('pesan yang bukan catatan makan tidak dicatat', () async {
    final d = FakeData();
    await run('tadi saya tidak makan nasi', d);
    await run('tadi saya masak nasi', d);
    await run('nasi sudah matang', d);
    expect(d.eaten, isEmpty);
    final r = await run('kemarin saya makan mi instan', d);
    expect(r!.text, contains('hanya untuk hari ini'));
    expect(d.eaten, isEmpty);
  });

  test('hari tanpa catatan dan energi berlebih', () async {
    final d = FakeData();
    expect((await run('sudah berapa kalori hari ini?', d))!.text, contains('Belum ada catatan makan'));
    expect((await run('hari ini saya makan apa saja?', d))!.text, contains('Belum ada catatan makan'));
    final r = await run('tadi saya makan mi instan 600 gram', d);
    expect(r!.text, contains('sudah melewati kebutuhan harian'));
  });

  test('makan di luar jendela puasa tetap dicatat dengan catatan', () async {
    final now = DateTime.now();
    final d = FakeData()..fasting = FastingPlan(18, ((now.hour + 3) % 24) * 60);
    final r = await run('barusan saya makan nasi', d);
    expect(d.eaten, hasLength(1));
    expect(r!.text, contains('di luar jendela makan'));
  });

  test('pertanyaan puasa dibedakan dari pertanyaan makanan dan puasa Ramadan', () async {
    final d = FakeData()..fasting = const FastingPlan(16, 12 * 60);
    expect((await run('boleh makan sekarang?', d))!.actions, ['puasa']);
    expect((await run('boleh makan mi instan?', d))?.actions ?? const [], isNot(contains('puasa')));
    expect((await run('lagi puasa nih, masak apa ya buat nanti', FakeData()))?.actions ?? const [], isNot(contains('puasa')));
    await run('atur puasa 16:8 mulai makan jam 1 siang', d);
    expect(d.fasting!.startMinute, 13 * 60);
    await run('atur puasa 18:6 mulai makan jam 7 malam', d);
    expect(d.fasting!.startMinute, 19 * 60);
  });

  test('data tubuh: usia di bawah 18 dan angka yang bukan ukuran tubuh', () async {
    final d = FakeData();
    expect((await run('tinggi 150 cm berat 40 kg umur 15 perempuan', d))!.text, contains('18 tahun ke atas'));
    expect(d.body, isNull);
    expect(await run('potong wortel 2 cm', d), isNull);
    expect(await run('nenek saya 70 tahun suka bubur', d), isNull);
    expect((await run('umur saya 30 tahun', d))!.actions, ['tubuh']);
  });

  test('kebutuhan energi tidak dinaikkan oleh batas bawah, dan ditambah untuk berat badan kurang', () {
    const small = BodyProfile(heightCm: 150, weightKg: 60, age: 70, male: true, activity: 'jarang');
    expect(needsFor(small, goal: 'turun').energy, needsFor(small).energy);
    const thin = BodyProfile(heightCm: 170, weightKg: 50, age: 25, male: false);
    expect(needsFor(thin, goal: 'turun').energy - needsFor(thin).energy, 300);
  });

  test('puasa berselang diatur dan ditanya', () async {
    final d = FakeData();
    final r = await run('atur puasa 16:8 mulai makan jam 11', d);
    expect(r!.text, contains('makan pukul 11.00 sampai 19.00'));
    expect(d.fasting!.fastHours, 16);
    expect((await run('kapan saya boleh makan? saya lagi puasa', d))!.text, contains('16:8'));
    await run('matikan puasa', d);
    expect(d.fasting, isNull);
  });

  test('status puasa dihitung dari jam', () {
    const p = FastingPlan(16, 12 * 60);
    expect(fastingState(p, DateTime(2026, 10, 10, 13)).eating, isTrue);
    final st = fastingState(p, DateTime(2026, 10, 10, 21));
    expect(st.eating, isFalse);
    expect(st.next, DateTime(2026, 10, 11, 12));
    expect(fastingState(const FastingPlan(16, 20 * 60), DateTime(2026, 10, 11, 1)).eating, isTrue); // jendela melewati tengah malam
  });

  test('buka fitur dari obrolan', () async {
    expect((await run('buka kalkulator', FakeData()))!.actions, contains('tubuh'));
    expect((await run('tolong buka buku resep', FakeData()))!.actions, ['resep']);
    expect(await run('apa bedanya rendang dan kalio?', FakeData()), isNull);
  });

  test('label gizi kemasan dibaca dan dijawab per sajian dan per kemasan', () {
    TextLine l(String t, double y, [double x = .2]) => TextLine(t, .9, [x, y, x + .3, y + .02]);
    final lines = [
      l('INFORMASI NILAI GIZI', .10),
      l('Takaran saji 25 g', .14),
      l('Jumlah Sajian per Kemasan : 4', .17),
      l('Energi total', .21),
      l('130 kkal', .21, .6),
      l('Lemak total', .25),
      l('6 g', .25, .6),
      l('Protein', .28),
      l('2 g', .28, .6),
      l('Karbohidrat total', .31),
      l('17 g', .31, .6),
      l('Gula', .34),
      l('Og', .34, .6),
      l('Garam (Natrium)', .37),
      l('290 mg', .37, .6),
    ];
    final label = nutritionLabel(lines)!;
    expect(label.energy, 130);
    expect(label.servings, 4);
    expect(label.sugar, 0);
    expect(label.sodium, 290);
    final t = Targets.of(null);
    final a = labelAnswer(label, t);
    expect(a, contains('Satu sajian memenuhi sekitar 6% energi'));
    expect(a, contains('Bila satu kemasan (4 sajian) dihabiskan sekaligus, energinya sekitar 520 kkal'));
    expect(a, contains('sebaiknya cukup 2 sajian'));
    expect(a, contains('tekanan darah tinggi'));
  });

  test('obrolan santai: perkenalan, minta bantuan, dan tidak suka bahan', () async {
    final d = FakeData();
    final r = await run('saya khai', d);
    expect(r!.text, startsWith('Halo, Khai!'));
    expect(d.userName, 'Khai');
    expect(await run('saya lapar', d), isNull);
    expect(await run('aku diet', d), isNull);
    expect((await run('bantu saya', d))!.actions, contains('gizi'));
    final it = ruleIntent('aku ga suka semangka');
    expect(it.exclude, contains('watermelon'));
    expect(it.include, isNot(contains('watermelon')));
    expect(ruleIntent('gk suka tomat dong').exclude, contains('tomato'));
  });
}
