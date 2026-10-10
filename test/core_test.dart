import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/grounding.dart';
import 'package:meira/core/health.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/core/vocab.dart';
import 'package:meira/llm/memory.dart';
import 'package:meira/llm/retriever.dart';

void main() {
  group('kosakata', () {
    test('label bebas dipetakan ke kunci bahan', () {
      expect(resolve('Pisang'), 'banana');
      expect(resolve('sliced tomatoes'), 'tomato');
      expect(resolve('mangkuk berisi apel'), 'apple');
      expect(resolve('kacang hijau'), 'mung_bean');
      expect(resolve('kotak'), isNull);
      expect(isNonFood('tanda harga'), isTrue);
    });

    test('bahan disebut dalam kalimat', () {
      expect(mentions('aku punya wortel, kentang dan bawang merah'), ['carrot', 'potato', 'shallot']);
    });
  });

  group('grounding', () {
    test('format ringkas dibaca dan dinomori kiri ke kanan', () {
      final d = parseDetections('jeruk bali* 500 100 900 600\npisang 100 200 300 400\nkotak 0 0 50 50');
      expect(d.map((e) => (e.number, e.label, e.group)).toList(), [(1, 'pisang', false), (2, 'jeruk bali', true)]);
    });

    test('JSON dari model zero-shot tetap terbaca', () {
      final d = parseDetections('```json\n[{"bbox_2d": [10, 10, 200, 200], "label": "apel"}]\n```');
      expect(d.single.key, 'apple');
    });

    test('jawaban verifikasi', () {
      expect(parseVerify('tidak ada').$1, isFalse);
      final (ok, boxes) = parseVerify('ada\n100 200 300 400');
      expect(ok, isTrue);
      expect(boxes.single, [.1, .2, .3, .4]);
    });

    test('jumlah memakai satuan alami', () {
      final dets = number([
        for (var i = 0; i < 5; i++) Detection(key: 'grapefruit', label: 'jeruk bali', rawLabel: 'jeruk bali', box: [i * .1, 0, i * .1 + .08, .1]),
        Detection(key: 'grape', label: 'anggur', rawLabel: 'anggur', box: [.6, .5, .8, .9]),
        Detection(key: 'pasta', label: 'pasta', rawLabel: 'pasta', box: [.85, .1, .99, .4]),
      ]);
      final g = {for (final x in grouped(dets)) x.key: x.count};
      expect(g, {'grapefruit': '5 buah', 'grape': '1 tandan', 'pasta': ''});
    });
  });

  group('resep', () {
    final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());

    test('buku resep terbaca utuh', () {
      // buku di aplikasi hanya memuat resep yang bahan utamanya dapat dideteksi; jumlahnya ikut naik bila model membaik
      expect(recipes.length, greaterThanOrEqualTo(30));
      expect(recipes.every((r) => r.items.every((i) => ingredients.containsKey(i.key))), isTrue);
    });

    test('peringkat mengikuti bahan di foto', () {
      final top = rank(recipes, {'banana', 'milk'}, Prefs()).first;
      expect(top.recipe.id, 'smoothie-pisang-susu');
    });

    test('mode enak dan sehat mendahulukan resep yang lebih ringan dan menyebut perbedaannya', () {
      final sehat = Prefs()..healthy = true;
      for (final have in [
        {'chicken'},
        {'corn'},
        {'potato', 'carrot'},
        {'tofu', 'tempeh'},
      ]) {
        final enak = rank(recipes, have, Prefs()).first.recipe;
        final ringan = rank(recipes, have, sehat).first.recipe;
        expect(isHealthy(ringan), isTrue, reason: have.join(' dan '));
        expect(healthScore(ringan), greaterThan(healthScore(enak)), reason: have.join(' dan '));
        expect(healthNote(ringan, tastier: enak), contains('Mode Enak & sehat aktif'));
      }
      // bila semua pilihan berat, resep berat tidak disebut sebagai pilihan sehat
      final tempe = rank(recipes, {'tempeh'}, sehat).first.recipe;
      if (healthScore(tempe) < heavyBelow) expect(healthNote(tempe), startsWith('Buku resep belum punya pilihan yang lebih ringan'));
    });

    test('pemahaman permintaan', () {
      final a = ruleIntent('yang lain dong, jangan pedas, cuma punya 10 menit');
      expect(a.action, 'ganti');
      expect(a.maxMinutes, 10);
      expect(a.exclude, contains('chili'));
      expect(ruleIntent('bahannya apa saja?').action, 'hidangan');
      expect(ruleIntent('apakah ada telur di foto?').action, 'cek');
      expect(ruleIntent('mau yang kedua').choice, 2);
    });
  });

  test('resep dicari menurut nama dengan ejaan yang bervariasi', () {
    final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());
    String? id(String q) => findRecipe(recipes, q)?.id;
    expect(id('resep soto ayam'), 'soto-ayam');
    expect(id('cara bikin sup buntut'), 'sop-buntut');
    expect(id('mi ayam'), 'mie-ayam');
    expect(id('ketoprak tanpa lontong'), 'ketoprak');
    expect(id('resep pempek'), 'pempek-ikan');
    expect(id('klepon'), 'klepon');
    expect(id('resep nasi goreng telur'), 'nasi-goreng-telur');
  });

  test('rujukan nomor yang salah dibuang', () {
    final d = [
      Detection(key: 'banana', label: 'pisang', rawLabel: 'pisang', box: [0, 0, .1, .1], number: 1),
      Detection(key: 'apple', label: 'apel', rawLabel: 'apel', box: [.2, 0, .3, .1], number: 2),
    ];
    final out = fixRefs('Siapkan pir (#1) saja, apel (#2 #5) sudah ada. KANDIDAT LAIN seperti salad. Tawarkan langkahnya. Selamat — mencoba!', d);
    expect(out, 'Siapkan pir saja, apel (#2) sudah ada. pilihan lain seperti salad. Selamat, mencoba!');
  });

  group('LLM', () {
    test('memori meringkas giliran lama dan menjaga anggaran', () {
      final m = ConversationMemory(budgetTokens: 60);
      for (var i = 0; i < 6; i++) {
        m.add('pertanyaan nomor $i tentang resep sup wortel', 'Jawaban nomor $i. Ini kalimat kedua yang cukup panjang untuk dihitung.');
      }
      final w = m.window();
      expect(w.first['role'], 'system');
      expect(w.first['content'], contains('Ringkasan percakapan'));
      expect(w.where((e) => e['role'] == 'user').length, lessThan(6));
      expect(w.last['content'], contains('Jawaban nomor 5'));
    });

    test('retriever menemukan resep dari teks bebas', () {
      final r = RecipeRetriever(parseRecipes(File('assets/resep.md').readAsStringSync()));
      // resep aktif bergantung pada kelas yang dapat dideteksi, jadi resep uji diambil dari buku itu sendiri
      final target = r.recipes.firstWhere((x) => x.name.split(' ').length >= 2);
      expect(r.search('aku mau bikin ${target.name.toLowerCase()}').first.recipe.id, target.id);
      expect(r.search('resep ${r.recipes.last.name.toLowerCase()}').first.recipe.id, r.recipes.last.id);
      expect(r.search('qwerty zxcv'), isEmpty);
    });
  });
}
