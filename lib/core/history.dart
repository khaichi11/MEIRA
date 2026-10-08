/// Riwayat percakapan di perangkat (SQLite), dengan batas jumlah sesi dan ukuran foto.
library;

import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../runtime/device.dart';

class HistoryEntry {
  HistoryEntry(this.id, this.title, this.updated, this.messages, this.last, this.hasPhoto);
  final String id;
  final String title;
  final DateTime updated;
  final int messages;
  final String last;
  final bool hasPhoto;
}

class StoredMessage {
  StoredMessage(this.role, this.text, this.meta);
  final String role;
  final String text;
  final Map<String, dynamic> meta;
}

class History {
  History._(this._db, this._photos);
  final Database _db;
  final Directory _photos;
  static const maxSessions = 200;
  static const maxPhotoBytes = 300 * 1024 * 1024;

  /// [factory] dan [at] hanya diisi saat uji di laptop (sqflite FFI dan folder sementara).
  static Future<History> open({Directory? at, DatabaseFactory? factory}) async {
    final dir = at ?? await Device.dataDir();
    final photos = Directory('${dir.path}/photos');
    await photos.create(recursive: true);
    final db = await (factory ?? databaseFactory).openDatabase(
      '${dir.path}/history.db',
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE sessions (id TEXT PRIMARY KEY, created INTEGER, updated INTEGER, title TEXT, state TEXT)');
          await db.execute(
            'CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id TEXT REFERENCES sessions(id) ON DELETE CASCADE, '
            'ts INTEGER, role TEXT, text TEXT, meta TEXT)',
          );
          await db.execute('CREATE INDEX idx_msg ON messages(session_id, id)');
        },
      ),
    );
    return History._(db, photos);
  }

  File photoFile(String sid) => File('${_photos.path}/$sid.jpg');
  File thumbFile(String sid) => File('${_photos.path}/${sid}_t.png');

  Future<void> savePhoto(String sid, List<int> jpeg, List<int> thumbPng) async {
    await photoFile(sid).writeAsBytes(jpeg);
    await thumbFile(sid).writeAsBytes(thumbPng);
  }

  Future<void> saveSession(String sid, String title, Map<String, dynamic> state) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.rawInsert(
      'INSERT INTO sessions(id, created, updated, title, state) VALUES (?, ?, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET updated=excluded.updated, title=excluded.title, state=excluded.state',
      [sid, now, now, title, jsonEncode(state)],
    );
    await _prune();
  }

  Future<void> addMessage(String sid, String role, String text, [Map<String, dynamic> meta = const {}]) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.rawInsert('INSERT OR IGNORE INTO sessions(id, created, updated, title, state) VALUES (?, ?, ?, ?, ?)', [sid, now, now, '', '{}']);
    await _db.insert('messages', {
      'session_id': sid,
      'ts': now,
      'role': role,
      'text': text.length > 4000 ? text.substring(0, 4000) : text,
      'meta': jsonEncode(meta),
    });
  }

  Future<List<HistoryEntry>> list({int limit = 200}) async {
    final rows = await _db.rawQuery(
      'SELECT s.id, s.title, s.updated, (SELECT COUNT(*) FROM messages m WHERE m.session_id = s.id) AS n, '
      "(SELECT text FROM messages m WHERE m.session_id = s.id AND m.role = 'assistant' ORDER BY m.id DESC LIMIT 1) AS last "
      'FROM sessions s ORDER BY s.updated DESC LIMIT ?',
      [limit],
    );
    return [
      for (final r in rows)
        HistoryEntry(
          r['id'] as String,
          (r['title'] as String?) ?? '',
          DateTime.fromMillisecondsSinceEpoch(r['updated'] as int),
          r['n'] as int,
          (r['last'] as String?) ?? '',
          thumbFile(r['id'] as String).existsSync(),
        ),
    ];
  }

  Future<(Map<String, dynamic>, List<StoredMessage>)?> load(String sid) async {
    final s = await _db.query('sessions', where: 'id = ?', whereArgs: [sid]);
    if (s.isEmpty) return null;
    final m = await _db.query('messages', where: 'session_id = ?', whereArgs: [sid], orderBy: 'id');
    return (
      jsonDecode(s.first['state'] as String) as Map<String, dynamic>,
      [for (final r in m) StoredMessage(r['role'] as String, r['text'] as String, jsonDecode(r['meta'] as String) as Map<String, dynamic>)],
    );
  }

  Future<void> delete(String sid) async {
    await _db.delete('sessions', where: 'id = ?', whereArgs: [sid]);
    for (final f in [photoFile(sid), thumbFile(sid)]) {
      if (f.existsSync()) await f.delete();
    }
  }

  Future<void> clear() async {
    await _db.delete('messages');
    await _db.delete('sessions');
    for (final f in _photos.listSync()) {
      await f.delete();
    }
    await _db.execute('VACUUM');
  }

  Future<(int sessions, int messages, int bytes)> usage() async {
    final n = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM sessions')) ?? 0;
    final m = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM messages')) ?? 0;
    var bytes = 0;
    for (final f in _photos.listSync().whereType<File>()) {
      bytes += f.lengthSync();
    }
    return (n, m, bytes);
  }

  /// Batas jumlah sesi, lalu batas ukuran: foto sesi tertua dibuang lebih dulu, teks tetap disimpan.
  Future<void> _prune() async {
    final n = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM sessions')) ?? 0;
    if (n > maxSessions) {
      final old = await _db.rawQuery('SELECT id FROM sessions ORDER BY updated ASC LIMIT ?', [n - maxSessions]);
      for (final r in old) {
        await delete(r['id'] as String);
      }
    }
    final photos = _photos.listSync().whereType<File>().where((f) => f.path.endsWith('.jpg')).toList()
      ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
    var total = photos.fold<int>(0, (a, f) => a + f.lengthSync());
    for (final f in photos) {
      if (total <= maxPhotoBytes * .9) break;
      total -= f.lengthSync();
      await f.delete();
    }
  }
}
