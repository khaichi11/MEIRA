/// Perintah obrolan yang membaca dan mengubah data fitur aplikasi: mencatat berat badan, mengisi data tubuh, menjawab
/// IMT, kebutuhan harian, progres berat, jejak masak, dan rencana makan, serta membuka fitur yang diminta.
///
/// Angka selalu dihitung di sini dari data pengguna, bukan dikarang model bahasa. Setiap jawaban boleh membawa tombol
/// aksi ([ToolReply.actions]) yang ditampilkan di bawah balasan, misalnya "Buka Gizi Seimbang".
library;

import 'body.dart';
import 'fasting.dart';
import 'health.dart';
import 'intake.dart';
import 'recipes.dart';

/// Data fitur yang dibaca dan diubah lewat obrolan; diterapkan oleh AppState.
abstract class AppData {
  BodyProfile? get body;
  DailyNeeds? get needs;
  String? get healthGoal;
  List<(DateTime, double)> get weights;
  int get streak;
  int get bestStreak;
  int get cookedTotal;
  List<Recipe> get recipes;
  List<Food> get foods;
  FastingPlan? get fasting;
  Future<bool> setFasting(FastingPlan? plan);
  List<IntakeEntry> get intakeToday;
  Future<void> logWeight(double kg);
  Future<void> setBody(BodyProfile b);
  Future<void> logIntake(IntakeEntry e);
  Future<void> removeLastIntake();
}

/// Makanan dengan nama terpanjang yang disebut dalam teks ("mi instan" sebelum "mi").
Food? findFood(String text, List<Food> foods) {
  final t = ' ${text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ').replaceAll(RegExp(r'\s+'), ' ')} ';
  Food? best;
  var len = 0;
  for (final f in foods) {
    for (final n in f.names) {
      if (n.length > len && t.contains(' ${n.toLowerCase()} ')) {
        best = f;
        len = n.length;
      }
    }
  }
  return best;
}

final _ate = RegExp(
  r'\b(tadi|barusan|sudah|udah|habis|baru saja|catat|saya makan|aku makan|saya minum|aku minum|sarapan saya|sarapanku|'
  r'makan siang saya|makan malam saya|nyemil|ngemil)\b',
);
final _notLog = RegExp(r'\b(resep|cara|bikin|membuat|masak apa|mau makan|ingin makan|boleh|cocok|sehat|apakah|berapa kalori)\b');

/// Rute fitur yang bisa dibuka dari tombol aksi di obrolan.
const routeLabels = {
  'gizi': 'Buka Gizi Seimbang',
  'tubuh': 'Isi data tubuh',
  'resep': 'Buka buku resep',
  'tur': 'Lihat tur fitur',
  'info': 'Sumber data dan rumus',
  'puasa': 'Atur puasa berselang',
};

class ToolReply {
  const ToolReply(this.text, {this.actions = const [], this.effect});
  final String text;
  final List<String> actions; // kunci rute dari [routeLabels]
  final Future<void> Function()? effect;
}

String fmt(double v, [int digits = 1]) {
  final s = v.toStringAsFixed(digits).replaceAll('.', ',');
  return s.endsWith(',0') ? s.substring(0, s.length - 2) : s;
}

String _thousands(int v) => v >= 1000 ? '${v ~/ 1000}.${(v % 1000).toString().padLeft(3, '0')}' : '$v';

const _months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
String _date(DateTime d) => '${d.day} ${_months[d.month - 1]}';

final _num = r'(\d{1,3}(?:[.,]\d{1,2})?)';
final _weight = RegExp('(?:berat(?: badan)?|\\bbb)(?: saya| aku| ku| sekarang| hari ini| tadi pagi| sudah| jadi| adalah|:)*\\s*$_num\\s*(?:kg|kilo)');
final _weightLoose = RegExp('$_num\\s*(?:kg|kilo(?:gram)?)\\b');
final _height = RegExp('(?:tinggi(?: badan)?(?: saya| aku)?\\s*:?\\s*$_num\\s*(?:cm)?|$_num\\s*cm)');
final _age = RegExp('(?:(?:umur|usia)(?: saya| aku)?\\s*:?\\s*(\\d{2})|(\\d{2})\\s*(?:tahun|th)\\b)');
final _male = RegExp(r'\b(laki-laki|laki|pria|cowok)\b');
final _female = RegExp(r'\b(perempuan|wanita|cewek)\b');
final _mine = RegExp(r'\b(saya|aku|ku|gue|gw)\b');
final _open = RegExp(r'\b(buka|lihat|tampilkan|pergi ke|ke)\b');

double? _parse(String? v) => v == null ? null : double.tryParse(v.replaceAll(',', '.'));

/// Balasan untuk perintah fitur, atau null bila pesan ini bukan perintah fitur.
ToolReply? appTool(String text, AppData d) {
  final t = text.toLowerCase();

  // buka fitur
  if (_open.hasMatch(t)) {
    if (RegExp(r'\b(kalkulator|data tubuh|imt|bmi)\b').hasMatch(t)) {
      return const ToolReply('Silakan isi atau periksa data tubuh Anda di kalkulator.', actions: ['tubuh', 'gizi']);
    }
    if (RegExp(r'\b(gizi seimbang|program (sehat|gizi|diet)|progres berat)\b').hasMatch(t)) {
      return const ToolReply('Silakan buka Gizi Seimbang untuk melihat IMT, progres berat, dan rencana makan hari ini.', actions: ['gizi']);
    }
    if (RegExp(r'\b(buku resep|daftar resep|semua resep)\b').hasMatch(t)) {
      return const ToolReply('Silakan buka buku resep untuk mencari resep menurut nama atau bahan.', actions: ['resep']);
    }
    if (RegExp(r'\b(tur|panduan|cara pakai)\b').hasMatch(t)) {
      return const ToolReply('Tur singkat menjelaskan fitur utama MEIRA dalam beberapa langkah.', actions: ['tur']);
    }
  }

  // data tubuh lengkap atau sebagian: "tinggi 165 cm, berat 80 kg, umur 30, laki-laki"
  final h = _parse(_height.firstMatch(t)?.group(1) ?? _height.firstMatch(t)?.group(2));
  final a = _age.firstMatch(t);
  final age = int.tryParse(a?.group(1) ?? a?.group(2) ?? '');
  final w = _parse(_weight.firstMatch(t)?.group(1) ?? (h != null || age != null ? _weightLoose.firstMatch(t)?.group(1) : null));
  final male = _male.hasMatch(t) ? true : (_female.hasMatch(t) ? false : null);
  if (h != null && (h < 100 || h > 230)) return null;
  if (w != null && (w < 25 || w > 300)) return null;
  if (h != null || age != null) {
    final b = d.body;
    final height = h ?? b?.heightCm, weight = w ?? b?.weightKg, years = age ?? b?.age, isMale = male ?? b?.male;
    if (height == null || weight == null || years == null || isMale == null) {
      final missing = [
        if (height == null) 'tinggi badan',
        if (weight == null) 'berat badan',
        if (years == null) 'usia',
        if (isMale == null) 'jenis kelamin',
      ];
      return ToolReply('Untuk menghitung kebutuhan harian, sebutkan juga ${_join(missing)} Anda, atau isi di kalkulator.', actions: const ['tubuh']);
    }
    final p = BodyProfile(heightCm: height, weightKg: weight, age: years, male: isMale, activity: b?.activity ?? 'ringan');
    final n = needsFor(p, goal: d.healthGoal);
    return ToolReply(
      'Data tubuh tersimpan. IMT Anda ${fmt(n.bmi)} (${n.category.toLowerCase()}), berat badan ideal ${fmt(n.idealMin)} sampai '
      '${fmt(n.idealMax)} kg, dan kebutuhan energi sekitar ${_thousands(n.energy)} kkal sehari.',
      actions: const ['gizi'],
      effect: () async {
        await d.setBody(p);
        if (w != null) await d.logWeight(w);
      },
    );
  }

  // catat berat: "berat saya sekarang 78 kg"
  if (w != null) {
    final before = d.weights.isEmpty ? null : d.weights.first;
    final b = d.body;
    final change = before == null ? '' : _change(before, w);
    final bmi = b == null ? '' : ' IMT Anda sekarang ${fmt(w / ((b.heightCm / 100) * (b.heightCm / 100)))}.';
    return ToolReply(
      'Baik, berat ${fmt(w)} kg dicatat.$change$bmi',
      actions: [if (b == null) 'tubuh', 'gizi'],
      effect: () async {
        await d.logWeight(w);
        if (b != null) {
          await d.setBody(BodyProfile(heightCm: b.heightCm, weightKg: w, age: b.age, male: b.male, activity: b.activity));
        }
      },
    );
  }

  // "boleh makan sekarang?" saat jadwal puasa aktif dijawab dari jadwalnya
  if (d.fasting != null && RegExp(r'\b(boleh makan|sudah boleh makan|waktunya makan|bisa makan sekarang)\b').hasMatch(t)) {
    final f = d.fasting!, st = fastingState(f, DateTime.now());
    return ToolReply(
      st.eating
          ? 'Boleh, sekarang masih waktu makan sampai pukul ${clock(f.endMinute)}.'
          : 'Menurut jadwal ${f.name}, sebaiknya tunggu sampai pukul ${clock(f.startMinute)}, ${untilText(st.next, DateTime.now())} lagi. '
                'Bila merasa pusing atau lemas, makanlah; jadwal bisa digeser kapan saja.',
      actions: const ['puasa'],
    );
  }

  // puasa berselang: atur, matikan, atau tanya status
  if (RegExp(r'\b(puasa berselang|intermittent fasting|puasa)\b').hasMatch(t) &&
      !RegExp(r'\b(ramadan|ramadhan|sahur|buka puasa|takjil)\b').hasMatch(t)) {
    final plan = RegExp(r'\b(12|14|16|18)\s*[:/]\s*(12|10|8|6)\b').firstMatch(t);
    final hours = plan == null ? int.tryParse(RegExp(r'\b(12|14|16|18) jam\b').firstMatch(t)?[1] ?? '') : int.parse(plan[1]!);
    if (RegExp(r'\b(matikan|hentikan|berhenti|stop|nonaktifkan)\b').hasMatch(t)) {
      return ToolReply('Puasa berselang dimatikan dan pengingatnya dihapus.', effect: () => d.setFasting(null));
    }
    if (hours != null && FastingPlan.options.contains(hours)) {
      final at = RegExp(r'\bjam (\d{1,2})(?:[.:](\d{2}))?').firstMatch(t);
      final start = at == null ? 12 * 60 : (int.parse(at[1]!) % 24) * 60 + int.parse(at[2] ?? '0');
      final p = FastingPlan(hours, start);
      return ToolReply(
        'Puasa berselang ${p.name} diatur: makan pukul ${clock(p.startMinute)} sampai ${clock(p.endMinute)}, puasa di luar jam itu. '
        'Saya akan mengingatkan saat waktu makan dimulai dan selesai.',
        actions: const ['puasa'],
        effect: () => d.setFasting(p),
      );
    }
    final f = d.fasting;
    if (f == null) {
      return const ToolReply(
        'Puasa berselang belum diatur. Ketik misalnya "atur puasa 16:8 mulai makan jam 12", atau atur di Gizi Seimbang.',
        actions: ['puasa'],
      );
    }
    final st = fastingState(f, DateTime.now());
    return ToolReply(
      st.eating
          ? 'Sekarang waktu makan (pola ${f.name}). Jendela makan selesai pukul ${clock(f.endMinute)}, ${untilText(st.next, DateTime.now())} lagi.'
          : 'Sekarang masih jam puasa (pola ${f.name}). Anda boleh makan pukul ${clock(f.startMinute)}, ${untilText(st.next, DateTime.now())} lagi. '
                'Air putih, teh, atau kopi tanpa gula tetap boleh.',
      actions: const ['puasa'],
    );
  }

  // catat makanan: "tadi pagi saya makan mi instan 1 bungkus"
  if (_ate.hasMatch(t) && !_notLog.hasMatch(t) && !t.contains('?')) {
    final food = findFood(t, d.foods);
    if (food != null) {
      final (grams, portion) = gramsFrom(t, food);
      final slot = slotFor(t, DateTime.now());
      final entry = IntakeEntry(DateTime.now(), slot, food.name, grams, food.per100.scale(grams / 100));
      final total = [...d.intakeToday, entry].fold(const Nutrients(), (a, e) => a + e.nutrients);
      return ToolReply(
        'Dicatat untuk ${slot.toLowerCase()}: ${food.name} $portion, sekitar ${entry.nutrients.energy.round()} kkal. '
        '${daySummary(total, Targets.of(d.needs))}',
        actions: const ['gizi'],
        effect: () => d.logIntake(entry),
      );
    }
  }
  if (RegExp(r'\b(hapus|batalkan)\b.*\b(catatan makan|makanan) terakhir\b').hasMatch(t)) {
    if (d.intakeToday.isEmpty) return const ToolReply('Belum ada catatan makan hari ini.');
    final last = d.intakeToday.last;
    return ToolReply('Catatan ${last.food} untuk ${last.slot.toLowerCase()} sudah dihapus.', effect: d.removeLastIntake);
  }
  final askEaten =
      RegExp(r'\b(makan|makanan)\b').hasMatch(t) && RegExp(r'\b(hari ini|tadi)\b').hasMatch(t) && RegExp(r'\b(apa saja|apa aja)\b').hasMatch(t);
  if ((askEaten || RegExp(r'\b(masih aman|kelebihan|sudah lebih|melebihi)\b').hasMatch(t)) && _mine.hasMatch(t)) {
    final today = d.intakeToday;
    if (today.isEmpty) {
      return const ToolReply('Belum ada catatan makan hari ini. Ketik misalnya "tadi pagi saya makan nasi goreng 1 piring".', actions: ['gizi']);
    }
    final total = today.fold(const Nutrients(), (a, e) => a + e.nutrients);
    final bySlot = [
      for (final slot in mealSlots)
        if (today.any((e) => e.slot == slot)) '${slot.toLowerCase()} ${_join([for (final e in today.where((e) => e.slot == slot)) e.food])}',
    ];
    return ToolReply('Hari ini Anda mencatat ${_join(bySlot)}. ${daySummary(total, Targets.of(d.needs))}', actions: const ['gizi']);
  }

  final n = d.needs;
  final mine = _mine.hasMatch(t) || RegExp(r'\bberapa\b').hasMatch(t);
  ToolReply needBody() => const ToolReply(
    'Data tubuh Anda belum diisi. Sebutkan tinggi, berat, usia, dan jenis kelamin, misalnya "tinggi 165 cm, berat 60 kg, '
    'umur 25, perempuan", atau isi di kalkulator.',
    actions: ['tubuh'],
  );

  if (mine && RegExp(r'\b(imt|bmi|indeks massa tubuh)\b').hasMatch(t)) {
    if (n == null) return needBody();
    return ToolReply(
      'IMT Anda ${fmt(n.bmi)}, termasuk ${n.category.toLowerCase()}. Rentang normal untuk tinggi Anda adalah berat ${fmt(n.idealMin)} '
      'sampai ${fmt(n.idealMax)} kg.',
      actions: const ['gizi'],
    );
  }
  if (mine && RegExp(r'\bberat (badan )?ideal\b').hasMatch(t)) {
    if (n == null) return needBody();
    return ToolReply(
      'Berat badan ideal untuk tinggi Anda ${fmt(n.idealMin)} sampai ${fmt(n.idealMax)} kg, dan menurut rumus Broca sekitar '
      '${fmt(n.broca)} kg.',
      actions: const ['gizi'],
    );
  }
  if (mine && RegExp(r'\b(kebutuhan|butuh)\b.*\b(kalori|energi|gizi|protein|harian)\b|\bkalori (harian )?(saya|aku)\b').hasMatch(t)) {
    if (n == null) return needBody();
    return ToolReply(
      'Perkiraan kebutuhan harian Anda: energi ${_thousands(n.energy)} kkal, protein ${n.protein} g, dan karbohidrat ${n.carbs} g. '
      'Batasnya gula ${n.sugar} g, lemak ${n.fat} g, dan garam ${n.salt} g.',
      actions: const ['gizi'],
    );
  }
  if (RegExp(r'\bbatas (gula|garam|lemak)\b').hasMatch(t) && n != null && _mine.hasMatch(t)) {
    return ToolReply('Batas harian Anda: gula ${n.sugar} g, lemak ${n.fat} g, dan garam ${n.salt} g.', actions: const ['gizi']);
  }
  if (RegExp(r'\b(progres|perkembangan)\b.*\b(berat|diet|program)\b|\bberat (saya|aku) (sudah )?(turun|naik)').hasMatch(t)) {
    if (d.weights.isEmpty) {
      return const ToolReply('Belum ada catatan berat. Ketik misalnya "berat saya 70 kg" untuk mulai mencatat.', actions: ['gizi']);
    }
    final first = d.weights.first, last = d.weights.last;
    final target = n == null ? '' : ' Rentang ideal Anda ${fmt(n.idealMin)} sampai ${fmt(n.idealMax)} kg.';
    return ToolReply(
      'Berat terakhir ${fmt(last.$2)} kg pada ${_date(last.$1)}.${_change(first, last.$2)} Ada ${d.weights.length} catatan berat.$target',
      actions: const ['gizi'],
    );
  }
  if (RegExp(r'\b(streak|rentetan|jejak masak)\b|\bberapa (hari|kali) (saya |aku )?(sudah )?masak').hasMatch(t)) {
    if (d.cookedTotal == 0) {
      return const ToolReply('Belum ada masakan yang tercatat. Selesaikan mode memasak atau tandai "Sudah saya masak" di halaman resep.');
    }
    return ToolReply('Anda sudah mencatat ${d.cookedTotal} masakan. Rentetan saat ini ${d.streak} hari, dan yang terpanjang ${d.bestStreak} hari.');
  }
  if (RegExp(r'\b(rencana|menu) (makan|sehat|diet)\b').hasMatch(t)) {
    final plan = dailyPlan(d.recipes, DateTime.now());
    if (plan.isEmpty) return null;
    return ToolReply('Rencana makan hari ini: ${_join([for (final (slot, r) in plan) '${slot.toLowerCase()} ${r.name}'])}.', actions: const ['gizi']);
  }
  return null;
}

String _change((DateTime, double) first, double now) {
  final diff = now - first.$2;
  if (diff.abs() < .05) return ' Sama dengan catatan pertama pada ${_date(first.$1)}.';
  return ' ${diff < 0 ? 'Turun' : 'Naik'} ${fmt(diff.abs())} kg sejak ${_date(first.$1)}.';
}

String _join(List<String> xs) => xs.length <= 1 ? xs.join() : '${xs.sublist(0, xs.length - 1).join(', ')} dan ${xs.last}';

/// Satu baris fakta catatan makan hari ini untuk model bahasa, atau null bila belum ada catatan.
String? intakeFact(AppData d) {
  final today = d.intakeToday;
  if (today.isEmpty) return null;
  final total = today.fold(const Nutrients(), (a, e) => a + e.nutrients);
  final t = Targets.of(d.needs);
  return 'Catatan makan pengguna hari ini: ${_join([for (final e in today) '${e.food} (${e.slot.toLowerCase()})'])}. '
      'Totalnya sekitar ${total.energy.round()} dari ${t.energy.round()} kkal, gula ${total.sugar.round()} dari ${t.sugar.round()} g, '
      'lemak ${total.fat.round()} dari ${t.fat.round()} g, dan garam ${fmt(total.salt)} dari ${t.salt.round()} g.';
}
