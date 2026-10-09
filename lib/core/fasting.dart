/// Pembatasan waktu makan (time-restricted eating): jendela makan harian dan statusnya saat ini.
///
/// Pola yang tersedia 12:12, 14:10, 16:8, dan 18:6 (jam tanpa asupan energi : jam jendela makan). Pengguna memilih jam mulai makan; jam
/// selesai dihitung dari lamanya jendela makan. Ini hanya pengatur waktu, bukan anjuran medis.
library;

class FastingPlan {
  const FastingPlan(this.fastHours, this.startMinute);
  final int fastHours; // 12, 14, 16, atau 18
  final int startMinute; // menit sejak tengah malam saat jendela makan dibuka

  int get eatHours => 24 - fastHours;
  int get endMinute => (startMinute + eatHours * 60) % (24 * 60);
  String get name => '$fastHours:$eatHours';

  static const options = [12, 14, 16, 18];

  String encode() => '$fastHours|$startMinute';
  static FastingPlan? decode(String? s) {
    final p = s?.split('|');
    if (p == null || p.length != 2) return null;
    final f = int.tryParse(p[0]), m = int.tryParse(p[1]);
    return f == null || m == null ? null : FastingPlan(f, m);
  }
}

String clock(int minute) => '${(minute ~/ 60).toString().padLeft(2, '0')}.${(minute % 60).toString().padLeft(2, '0')}';

/// Status saat [now]: sedang boleh makan atau sedang puasa, waktu perubahan berikutnya, dan kemajuan tahap ini (0..1).
class FastingState {
  const FastingState(this.eating, this.next, this.progress);
  final bool eating;
  final DateTime next;
  final double progress;
}

FastingState fastingState(FastingPlan p, DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  DateTime at(int minute, int dayOffset) => day.add(Duration(days: dayOffset, minutes: minute));
  // jendela makan hari ini, kemarin, dan besok; jendela bisa melewati tengah malam
  for (final offset in [-1, 0, 1]) {
    final start = at(p.startMinute, offset);
    final end = start.add(Duration(hours: p.eatHours));
    if (!now.isBefore(start) && now.isBefore(end)) {
      return FastingState(true, end, now.difference(start).inSeconds / end.difference(start).inSeconds);
    }
  }
  // sedang puasa: jendela berikutnya adalah yang paling dekat di depan
  var nextStart = at(p.startMinute, 0);
  if (!nextStart.isAfter(now)) nextStart = at(p.startMinute, 1);
  final fastStart = nextStart.subtract(Duration(hours: p.fastHours));
  return FastingState(false, nextStart, (now.difference(fastStart).inSeconds / (p.fastHours * 3600)).clamp(0.0, 1.0));
}

String untilText(DateTime next, DateTime now) {
  final d = next.difference(now);
  final h = d.inHours, m = d.inMinutes % 60;
  return h > 0 ? '$h jam $m menit' : '$m menit';
}
