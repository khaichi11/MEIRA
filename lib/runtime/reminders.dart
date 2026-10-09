import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/fasting.dart';

/// Pengingat puasa berselang lewat notifikasi lokal: satu saat jendela makan dibuka dan satu saat ditutup, diulang
/// setiap hari. Jadwal tidak memakai alarm tepat waktu (cukup sekitar menit itu), jadi tidak perlu izin alarm khusus.
class Reminders {
  Reminders._();
  static final instance = Reminders._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationDetails(
    'puasa',
    'Puasa berselang',
    channelDescription: 'Pengingat saat waktu makan dimulai dan selesai',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_zone(DateTime.now().timeZoneOffset)));
    await _plugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    _ready = true;
  }

  /// Nama zona dari selisih jam; aplikasi ini terutama dipakai di Indonesia (WIB, WITA, WIT).
  static String _zone(Duration offset) => switch (offset.inMinutes) {
    420 => 'Asia/Jakarta',
    480 => 'Asia/Makassar',
    540 => 'Asia/Jayapura',
    final m when m % 60 == 0 => 'Etc/GMT${m > 0 ? '-' : '+'}${(m ~/ 60).abs()}',
    _ => 'UTC',
  };

  static const _cooking = AndroidNotificationDetails(
    'masak',
    'Pengatur waktu memasak',
    channelDescription: 'Pemberitahuan saat waktu langkah memasak habis',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Pemberitahuan saat pengatur waktu langkah memasak habis, juga bila aplikasi sedang di latar belakang.
  Future<void> cookTimer(DateTime at, String body) async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (!(await android?.requestNotificationsPermission() ?? true)) return;
    await _plugin.zonedSchedule(
      10,
      'Waktu habis',
      body,
      tz.TZDateTime.from(at, tz.local),
      const NotificationDetails(android: _cooking),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelCookTimer() async {
    await _init();
    await _plugin.cancel(10);
  }

  /// Pasang pengingat untuk [plan], atau hapus semuanya bila [plan] null. Mengembalikan false bila izin ditolak.
  Future<bool> schedule(FastingPlan? plan) async {
    await _init();
    await _plugin.cancel(1);
    await _plugin.cancel(2);
    if (plan == null) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final allowed = await android?.requestNotificationsPermission() ?? true;
    if (!allowed) return false;
    Future<void> daily(int id, int minute, String title, String body) {
      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, minute ~/ 60, minute % 60);
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
      return _plugin.zonedSchedule(
        id,
        title,
        body,
        at,
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    await daily(1, plan.startMinute, 'Waktu makan dimulai', 'Jendela makan ${plan.name} terbuka sampai pukul ${clock(plan.endMinute)}.');
    await daily(2, plan.endMinute, 'Waktu makan selesai', 'Puasa dimulai sampai pukul ${clock(plan.startMinute)} besok.');
    return true;
  }
}
