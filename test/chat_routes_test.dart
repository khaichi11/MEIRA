import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/body.dart';
import 'package:meira/core/history.dart';
import 'package:meira/core/intake.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/llm/knowledge.dart';

import 'tools_test.dart' show FakeData;

/// Riwayat di memori: rute obrolan diuji tanpa basis data.
class MemoryHistory implements History {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class BookData extends FakeData {
  BookData(this.list, this.book);
  final List<Food> list;
  final List<Recipe> book;
  @override
  List<Food> get foods => list;
  @override
  List<Recipe> get recipes => book;
}

void main() {
  final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());
  final kb = KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync(), facts: File('assets/pengetahuan_luas.jsonl').readAsStringSync());
  final foods = [
    for (final f in kb.facts)
      if (f.nutrition)
        if (Nutrients.parse(f.text) case final n?) Food(f.names.first, f.names, n),
  ];

  /// Jawaban akhir untuk satu pesan di tab [mode], tanpa model bahasa.
  Future<(String, String)> ask(String mode, String text, BookData data) async {
    final m = Meira(recipes: recipes, history: MemoryHistory(), eyes: null, brain: null, knowledge: kb, appData: data, needs: data.needs)
      ..chatMode = mode;
    var out = ('', '');
    await for (final ev in m.turn(Session('uji'), text: text)) {
      if (ev is DoneEvent) out = (ev.text, ev.source);
    }
    return out;
  }

  BookData data() => BookData(foods, recipes)..body = const BodyProfile(heightCm: 165, weightKg: 60, age: 25, male: false, activity: 'ringan');

  /// Beberapa pesan berurutan dalam satu sesi; mengembalikan jawaban dan sumber setiap pesan.
  Future<List<(String, String)>> talk(String mode, List<String> texts, [BookData? d]) async {
    final data0 = d ?? data();
    final m = Meira(recipes: recipes, history: MemoryHistory(), eyes: null, brain: null, knowledge: kb, appData: data0, needs: data0.needs)
      ..chatMode = mode;
    final s = Session('uji');
    final out = <(String, String)>[];
    for (final t in texts) {
      var last = ('', '');
      await for (final ev in m.turn(s, text: t)) {
        if (ev is DoneEvent) last = (ev.text, ev.source);
      }
      out.add(last);
    }
    return out;
  }

  test('cerita makan atau minum dicatat di kedua tab, termasuk es teh dan jumlah tanpa satuan', () async {
    final d = data();
    final (resep, source) = await ask('resep', 'saya minum 2 esteh', d);
    expect(source, 'fitur');
    expect(resep, contains('teh manis 2 gelas'));
    expect((await ask('gizi', 'pagi ini saya minum 2 esteh', d)).$1, startsWith('Dicatat untuk sarapan'));
    final mixed = (await ask('resep', 'halo meira pagi ini saya makan ayam goren 1 dan nasi satu juga', d)).$1;
    expect(mixed, contains('ayam goreng 1 potong'));
    expect(mixed, contains('nasi 1 piring'));
    expect(d.eaten.length, 4);
  });

  test('hidangan yang belum ada di data gizi dijawab terus terang, bukan dipecah atau diserahkan ke model', () async {
    expect((await ask('gizi', 'tadi saya makan sate ayam', data())).$1, contains('belum punya data gizi untuk sate ayam'));
    expect((await ask('gizi', 'kalau minum kopi susu tiap hari gimana?', data())).$1, startsWith('Data gizi untuk kopi susu belum ada'));
  });

  test('ucapan terima kasih tidak dijawab dengan catatan dapur', () async {
    expect((await ask('resep', 'makasih ya meira', data())).$1, startsWith('Sama-sama'));
    expect(smallTalkReply('halo meira'), startsWith('Halo'));
    expect(smallTalkReply('halo meira saya makan nasi'), isNull);
  });

  test('pertanyaan perbedaan dua makanan membandingkan keduanya', () async {
    final (answer, _) = await ask('gizi', 'lebih sehat mana nasi putih atau nasi merah', data());
    expect(answer, contains('nasi merah'));
    expect(answer, contains('nasi putih'));
    expect(answer, contains('Serat nasi merah lebih tinggi'));
    // ada catatan perbandingan gula, jadi catatan itu yang dipakai, bukan selisih angka gizi seperti natrium 1 dan 28 mg
    final sugar = (await ask('gizi', 'apa beda gula merah dan gula pasir', data())).$1;
    expect(sugar, contains('Gula pasir dibuat dari tebu'));
    expect(sugar, isNot(contains('Garam')));
  });

  group('konteks percakapan', () {
    test('puasa Ramadan diingat untuk pertanyaan berikutnya', () async {
      final r = await talk('gizi', ['saya lagi puasa ramadan', 'boleh minum kopi ga', 'sudah buka puasa']);
      expect(r[0].$1, contains('sahur dan berbuka'));
      expect(r[1].$1, contains('puasa Ramadan'));
      expect(r[2].$1, contains('sudah tidak berpuasa'));
    });

    test('puasa dengan jendela makan yang sudah diatur berarti pembatasan waktu makan', () async {
      final r = await talk('gizi', ['atur jendela makan 16:8 mulai jam 12', 'saya sedang puasa', 'boleh minum kopi ga']);
      expect(r[1].$1, contains('pukul 12.00 sampai 20.00'));
      expect(r[2].$1, contains('jendela makan'));
    });

    test('jawaban "iya" dan "nggak" mengikuti tawaran sebelumnya', () async {
      final yes = await talk('resep', ['sayur apa yang cocok buat anak', 'iya', 'berapa lama masaknya']);
      expect(yes[0].$1, endsWith('Apakah Anda ingin saya jelaskan langkah-langkahnya?'));
      expect(yes[1].$1, startsWith('Berikut cara membuat'));
      expect(yes[2].$1, contains('menit'));
      final no = await talk('resep', ['sayur apa yang cocok buat anak', 'nggak dulu', 'nggak']);
      expect(no[1].$1, startsWith('Baik.'));
      // tanpa tawaran, "nggak" tidak dianggap permintaan resep
      expect(no[2].$2, 'templat');
      expect(no[2].$1, startsWith('Baik.'));
    });

    test('hidangan dijelaskan dari ringkasan Wikipedia lalu resepnya ditawarkan', () async {
      final r = await talk('resep', ['apa itu klepon', 'iya']);
      expect(r[0].$1, contains('tepung ketan'));
      expect(r[0].$1, endsWith('Mau saya tampilkan?'));
      expect(r[1].$1, startsWith('Bagaimana kalau Klepon?'));
      final rendang = await talk('resep', ['jelaskan tentang rendang', 'rendang asalnya dari mana', 'bahannya apa aja']);
      expect(rendang[0].$2, 'fakta');
      expect(rendang[0].$1, contains('Minangkabau'));
      expect(rendang[1].$1, startsWith('Rendang berasal dari'));
      expect(rendang[2].$1, startsWith('Rendang Daging di buku resep MEIRA'));
    });

    test('pertanyaan di luar dapur tetap ditolak walau sedang membahas makanan', () async {
      final r = await talk('resep', ['apa itu cimol', 'siapa presiden indonesia']);
      expect(r[1].$2, 'pengaman');
    });

    test('keadaan kesehatan dan vegetarian ikut dipakai', () async {
      final sick = await talk('gizi', ['saya diabetes', 'buah yang aman apa']);
      expect(sick[0].$1, contains('dokter atau ahli gizi'));
      expect(sick[1].$1, contains('diabetes'));
      final veg = await talk('resep', ['saya vegetarian', 'masak apa ya hari ini']);
      final name = RegExp(r'Bagaimana kalau (.+?)\?').firstMatch(veg[1].$1)![1]!;
      expect(recipes.firstWhere((r) => r.name == name).tags, contains('vegetarian'));
    });

    test('memasak bisa dibatalkan dari obrolan', () async {
      final d = data();
      expect((await talk('resep', ['batal masak'], d))[0].$1, contains('belum ada catatan masak'));
      d.cooked.add('Klepon');
      expect((await talk('resep', ['ga jadi masak'], d))[0].$1, contains('Klepon'));
      expect(d.cooked, isEmpty);
    });
  });

  group('jawaban pengetahuan', () {
    test('zat gizi yang ditanyakan disebut lebih dulu', () async {
      expect((await ask('gizi', 'protein telur berapa', data())).$1, startsWith('Satu butir telur'));
    });

    test('hidangan tanpa data gizi memakai angka bahan dasarnya dengan terus terang', () async {
      final a = (await ask('gizi', 'tempe mendoan sehat ga buat diet', data())).$1;
      expect(a, startsWith('Data gizi untuk tempe mendoan belum ada'));
      expect(a, contains('digoreng'));
    });

    test('hidangan lain yang hanya berbagi kata tidak dijawab dengan resep yang salah', () async {
      expect((await ask('resep', 'gimana cara bikin kue lapis legit', data())).$1, isNot(startsWith('Berikut cara membuat Kue Lapis')));
    });

    test('kalimat catatan yang paling menjawab diletakkan di depan', () async {
      expect((await ask('resep', 'kenapa nasi saya lembek', data())).$1, startsWith('Nasi yang terlalu lembek'));
      final note = Note('Contoh', '', 'Untuk beras putih biasa, pakai air secukupnya. Nasi lembek berarti airnya kebanyakan.');
      expect(noteAnswer('kenapa nasi lembek', note), startsWith('Nasi lembek'));
      expect(noteAnswer('takaran air beras', note), startsWith('Untuk beras'));
    });

    test('pertanyaan definisi dikenali hanya bila menanyakan hidangan itu', () {
      expect(whatIs('apa itu klepon?', 'klepon'), isTrue);
      expect(whatIs('gudeg itu makanan apa sih', 'gudeg'), isTrue);
      expect(whatIs('jelaskan tentang rendang', 'rendang'), isTrue);
      expect(whatIs('buah apa yang cocok untuk diabetes', 'buah'), isFalse);
      expect(whatIs('resep klepon', 'klepon'), isFalse);
    });

    test('tulisan ulang model ditolak bila mengubah isi jawaban', () {
      const core = 'Boleh, tetapi sebaiknya sesekali saja. Rendang adalah olahan khas Minangkabau.';
      expect(voiceMatches(core, 'Masih boleh asalkan sesekali saja. Rendang itu olahan khas Minangkabau.', 'rendang sehat?'), isTrue);
      expect(voiceMatches(core, 'Boleh. Rendang itu olahan khas Minangkabau.', 'rendang sehat?'), isFalse);
      expect(voiceMatches(core, 'Boleh, tetapi sesekali saja. Rendang itu olahan daging.', 'rendang sehat?'), isFalse);
      expect(voiceMatches(core, 'Rendang sehat buat diet? Boleh sesekali, khas Minangkabau.', 'rendang sehat buat diet'), isFalse);
      expect(voiceMatches(core, 'Boleh sesekali, khas Minangkabau. Mau resepnya?', 'rendang sehat?'), isFalse);
    });
  });

  test('jawaban model yang terpotong di kata sambung dibuang', () {
    expect(completeSentences('Maaf, saya belum punya informasi pasti tentang'), '');
    expect(completeSentences('Nasi goreng enak. Bumbunya dari'), 'Nasi goreng enak.');
    expect(completeSentences('Tempe kaya protein'), 'Tempe kaya protein.');
  });
}
