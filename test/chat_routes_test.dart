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
    final sugar = (await ask('gizi', 'apa beda gula merah dan gula pasir', data())).$1;
    expect(sugar, contains('gula pasir'));
    // natrium 1 dan 28 mg bukan perbedaan yang berarti
    expect(sugar, isNot(contains('Garam')));
  });

  test('jawaban model yang terpotong di kata sambung dibuang', () {
    expect(completeSentences('Maaf, saya belum punya informasi pasti tentang'), '');
    expect(completeSentences('Nasi goreng enak. Bumbunya dari'), 'Nasi goreng enak.');
    expect(completeSentences('Tempe kaya protein'), 'Tempe kaya protein.');
  });
}
