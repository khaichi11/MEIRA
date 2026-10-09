// Gerbang mutu yang sama dengan scripts/eval_suite.py, dijalankan pada kode Dart aplikasi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/body.dart';
import 'package:meira/core/pipeline.dart';
import 'package:meira/core/recipes.dart';
import 'package:meira/core/vocab.dart';
import 'package:meira/llm/guardrails.dart';
import 'package:meira/llm/knowledge.dart';
import 'package:meira/llm/retriever.dart';

List<Map<String, dynamic>> _rows(String name) => [
  for (final l in File('test/fixtures/$name').readAsLinesSync())
    if (l.trim().isNotEmpty) jsonDecode(l) as Map<String, dynamic>,
];

double _gate(String key) => (jsonDecode(File('test/fixtures/gates.json').readAsStringSync())[key]['value'] as num).toDouble();

(double, double) _intentScores(String file) {
  var acc = 0, tp = 0, np = 0, ng = 0;
  final rows = _rows(file);
  for (final r in rows) {
    final p = ruleIntent(r['text']);
    if (p.action == r['action']) acc++;
    final gold = <String>{
      if (r['max_minutes'] != null) 'mm:${r['max_minutes']}',
      for (final t in (r['tags'] ?? []) as List) 'tag:$t',
      for (final k in (r['exclude'] ?? []) as List) 'ex:$k',
      for (final k in (r['include'] ?? []) as List) 'in:$k',
      if (r['choice'] != null) 'ch:${r['choice']}',
      if (r['ingredient'] != null) 'ing:${r['ingredient']}',
    };
    final pred = <String>{
      if (p.maxMinutes != null) 'mm:${p.maxMinutes}',
      for (final t in p.tags) 'tag:$t',
      for (final k in p.exclude) 'ex:$k',
      for (final k in p.include) 'in:$k',
      if (p.choice != null) 'ch:${p.choice}',
      if ((r['action'] == 'cek' || r['action'] == 'substitusi') && p.ingredient != null) 'ing:${resolve(p.ingredient!)}',
    };
    tp += pred.intersection(gold).length;
    np += pred.length;
    ng += gold.length;
  }
  final prec = np == 0 ? 1.0 : tp / np, rec = ng == 0 ? 1.0 : tp / ng;
  return (acc / rows.length, prec + rec == 0 ? 0 : 2 * prec * rec / (prec + rec));
}

void main() {
  final recipes = parseRecipes(File('assets/resep.md').readAsStringSync());

  test('pemahaman permintaan lolos gerbang (set pengembangan dan set terpisah)', () {
    final (acc, f1) = _intentScores('intents.jsonl');
    final (hAcc, hF1) = _intentScores('intents_holdout.jsonl');
    expect(acc, greaterThanOrEqualTo(_gate('intent_action_acc')));
    expect(f1, greaterThanOrEqualTo(_gate('intent_slot_f1')));
    expect(hAcc, greaterThanOrEqualTo(_gate('intent_holdout_action_acc')));
    expect(hF1, greaterThanOrEqualTo(_gate('intent_holdout_slot_f1')));
  });

  test('pencarian resep lolos gerbang (hanya resep yang aktif di aplikasi)', () {
    final ids = {for (final r in recipes) r.id};
    final retriever = RecipeRetriever(recipes);
    var hits = 0, n = 0;
    var rr = 0.0;
    for (final row in _rows('retrieval.jsonl')) {
      final expect_ = ((row['expect'] as List).cast<String>()).where(ids.contains).toSet();
      if (expect_.isEmpty) continue; // resep yang diharapkan belum aktif (bahan utamanya belum terdeteksi)
      List<String> ranked;
      if (row['type'] == 'text') {
        ranked = [for (final h in retriever.search(row['query'], k: 5)) h.recipe.id];
      } else {
        final p = Prefs.fromJson(Map<String, dynamic>.from(row['prefs'] ?? {}));
        ranked = [
          for (final m in rank(recipes, {...(row['have'] as List).cast<String>()}.difference(p.exclude), p, k: 5)) m.recipe.id,
        ];
      }
      n++;
      if (ranked.take(3).any(expect_.contains)) hits++;
      final pos = ranked.indexWhere(expect_.contains);
      if (pos >= 0) rr += 1 / (pos + 1);
    }
    expect(n, greaterThanOrEqualTo(10)); // hanya kueri yang resep harapannya aktif di aplikasi
    expect(hits / n, greaterThanOrEqualTo(_gate('retrieval_recall_at_3')));
    expect(rr / n, greaterThanOrEqualTo(_gate('retrieval_mrr')));
  });

  test('semua resep aktif bisa dipicu dari foto', () {
    final known = ingredients.keys.toSet();
    expect(recipes.every((r) => r.items.every((i) => known.contains(i.key))), isTrue);
    expect(recipes.every((r) => r.mainKeys.isNotEmpty), isTrue);
  });

  (double, double) guardScores(String file) {
    final retriever = RecipeRetriever(recipes);
    final kb = KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync());
    var ok = 0, allowRows = 0, falseBlock = 0;
    final rows = _rows(file);
    for (final r in rows) {
      final text = r['text'] as String;
      final r1 = retriever.search(text, k: 1, minScore: 0).where((h) => h.matched >= 2);
      final r2 = kb.search(text, k: 1, minScore: 0).where((h) => h.$3 >= 2);
      final score = [...r1.map((h) => h.score), ...r2.map((h) => h.$2), 0.0].reduce((a, b) => a > b ? a : b);
      final g = Guardrails.checkInput(text, knownIngredient: Guardrails.kitchenRequest(text), ragScore: score);
      if (g.verdict.name == r['expect']) ok++;
      if (r['expect'] == 'allow') {
        allowRows++;
        if (!g.allowed) falseBlock++;
      }
    }
    return (ok / rows.length, falseBlock / allowRows);
  }

  test('guardrails lolos gerbang dan tidak memblokir pertanyaan dapur', () {
    final (acc, fb) = guardScores('guardrails.jsonl');
    final (hAcc, hFb) = guardScores('guardrails_holdout.jsonl');
    final home = Platform.environment['MEIRA_HOME'] ?? '..';
    File('$home/runs/eval/guardrails.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode({
          'metrics': {'guardrail_accuracy': acc, 'guardrail_false_block': fb > hFb ? fb : hFb, 'guardrail_holdout_accuracy': hAcc},
        }),
      );
    expect(fb, lessThanOrEqualTo(_gate('guardrail_false_block')));
    expect(hFb, lessThanOrEqualTo(_gate('guardrail_false_block')));
    expect(hAcc, greaterThanOrEqualTo(_gate('guardrail_holdout_accuracy')));
    expect(acc, greaterThanOrEqualTo(_gate('guardrail_accuracy')));
  });

  test('penjelasan berputar terdeteksi', () {
    expect(Guardrails.isCircular('Orak-arik adalah orak-arik yang dimasak.'), isTrue);
    expect(Guardrails.isCircular('Orak-arik adalah telur yang diaduk terus selama dimasak.'), isFalse);
  });

  test('pertanyaan pengetahuan dapur diarahkan ke catatan yang benar', () {
    final kb = KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync());
    final rows = _rows('kb_questions.jsonl');
    var top1 = 0, routed = 0;
    for (final r in rows) {
      final hits = kb.search(r['text'], k: 1);
      if (hits.isNotEmpty && hits.first.$1.title == r['note']) top1++;
      final a = ruleIntent(r['text']).action;
      if (['obrolan', 'substitusi'].contains(a) || (a == 'rekomendasi' && chatQuestion(r['text'], kb))) routed++;
    }
    final home = Platform.environment['MEIRA_HOME'] ?? '..';
    File('$home/runs/eval/kb.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode({
          'metrics': {'kb_recall_at_1': top1 / rows.length, 'kb_routing': routed / rows.length},
        }),
      );
    expect(top1 / rows.length, greaterThanOrEqualTo(_gate('kb_recall_at_1')));
    expect(routed / rows.length, greaterThanOrEqualTo(_gate('kb_routing')));
  });

  test('permintaan resep tidak dialihkan ke catatan dapur', () {
    final kb = KnowledgeBase.parse(File('assets/pengetahuan.md').readAsStringSync());
    final wrong = [
      for (final f in ['intents.jsonl', 'intents_holdout.jsonl'])
        for (final r in _rows(f))
          if (r['action'] == 'rekomendasi' && chatQuestion(r['text'], kb)) r['text'],
    ];
    expect(wrong, isEmpty);
  });

  test('pertanyaan tentang sifat bahan tidak dijawab dengan rekomendasi resep', () {
    expect(ingredientQuestion('apel hijau rasanya beda nggak sama apel merah'), isTrue);
    expect(ingredientQuestion('kenapa pisang cepat menghitam'), isTrue);
    expect(ingredientQuestion('ada telur juga'), isFalse);
    expect(ingredientQuestion('saya punya apel dan pir, enaknya dibuat apa?'), isFalse);
    expect(ingredientQuestion('masih ada tomat nggak'), isFalse);
    expect(ingredientQuestion('pisang hijau itu pisang apa sih?'), isTrue);
    expect(ingredientQuestion('aku punya telur, bisa masak apa?'), isFalse);
  });

  test('jawaban yang mengarang ditolak, parafrase yang setia diterima', () {
    const ikan =
        'Ikan segar bermata jernih, insangnya merah cerah, dan dagingnya kenyal saat ditekan. Baunya segar seperti laut, bukan amis menyengat.';
    expect(Guardrails.supported('Ikan segar ditandai dengan warna hijau-putih, tekstur lunak, dan aroma khas tanpa kerusakan.', ikan), isFalse);
    expect(Guardrails.supported('Pilih ikan yang matanya jernih, insangnya merah cerah, dan dagingnya kenyal bila ditekan.', ikan), isTrue);
    const telur = 'Hitung waktu sejak air mendidih. Telur setengah matang sekitar 6 sampai 7 menit, matang penuh sekitar 10 sampai 12 menit.';
    expect(Guardrails.supported('Rebus telur setengah matang sekitar 6 sampai 7 menit sejak air mendidih.', telur), isTrue);
    expect(Guardrails.supported('Rebus telur setengah matang sekitar 4 menit.', telur), isFalse);
    const kentang = 'Simpan kentang di tempat gelap, sejuk, dan kering, terpisah dari bawang. Buang bagian yang hijau atau bertunas sebelum dimasak.';
    expect(Guardrails.supported('Ya, kentang dengan kulit kehijauan tetap bisa dicicipi dan dihidangkan sebagai topping.', kentang), isFalse);
  });

  test('gaya natural: tulisan ulang yang membalik status bahan ditolak', () {
    // kasus yang sama diperiksa scripts/make_paraphrase_sft.py, agar penyaring data latih dan aplikasi sepakat
    final cases = jsonDecode(File('test/fixtures/natural_cases.json').readAsStringSync()) as List;
    for (final c in cases) {
      expect(naturalMatches(c[0] as String, c[1] as String, ['Capcay Goreng', 'Mie Goreng Jawa']), c[2], reason: c[1] as String);
    }
    // angka baru dan bahan baru juga ditolak
    const core =
        'Saya menyarankan Telur Dadar Tomat, dengan waktu memasak sekitar 10 menit. Dari foto, sudah tersedia telur (#1). '
        'Apakah Anda ingin saya jelaskan langkah-langkahnya?';
    expect(
      naturalMatches(core, 'Telur Dadar Tomat cocok, sekitar 15 menit saja dengan telur (#1). Mau saya jelaskan langkahnya?', ['Telur Dadar Tomat']),
      isFalse,
    );
    expect(
      naturalMatches(core, 'Telur Dadar Tomat cocok, sekitar 10 menit dengan telur (#1) dan keju. Mau saya jelaskan langkahnya?', [
        'Telur Dadar Tomat',
      ]),
      isFalse,
    );
    expect(
      naturalMatches(core, 'Telur Dadar Tomat cocok karena hanya sekitar 10 menit, dan telur (#1) sudah ada. Mau saya jelaskan langkahnya?', [
        'Telur Dadar Tomat',
      ]),
      isTrue,
    );
  });

  test('koreksi isi foto dikenali, pertanyaan dan tambahan bahan tidak', () {
    expect(correction('ini buah naga'), 'buah naga');
    expect(correction('gambar yang saya berikan adalah buah naga'), 'buah naga');
    expect(correction('bukan kepiting, tapi buah naga'), 'buah naga');
    expect(correction('foto ini sebenarnya buah naga kok'), 'buah naga');
    expect(correction('itu telur'), 'telur');
    expect(correction('ini buah apa?'), isNull);
    expect(correction('ini ada telur juga'), isNull);
    expect(correction('ini telur dan tomat'), isNull);
  });

  test('sebutan berat badan dibuat sopan', () {
    expect(Guardrails.respectful('Resep ini cocok untuk orang gemuk.'), 'Resep ini cocok untuk orang dengan berat badan berlebih.');
    expect(Guardrails.respectful('Kegemukan bisa dicegah.'), 'berat badan berlebih bisa dicegah.');
    expect(Guardrails.respectful('Pilih daging yang tidak gemuk.'), 'Pilih daging yang tidak gemuk.');
  });

  test('kalkulator tubuh dan perbandingan gizi harian', () {
    final n = needsFor(const BodyProfile(heightCm: 165, weightKg: 80, age: 30, male: true, activity: 'ringan'), goal: 'turun');
    expect(n.bmi, closeTo(29.4, .1));
    expect(n.category, 'Obesitas');
    expect(n.idealMin, closeTo(50.4, .1));
    expect(n.idealMax, closeTo(68.1, .1));
    expect(n.broca, closeTo(58.5, .1));
    expect(n.energy, 1820); // (10*80 + 6,25*165 - 5*30 + 5) * 1,375 - 500 = 1.818,6
    expect(n.sugar, 45);
    expect(n.fat, 51);
    const mi =
        'Perkiraan kandungan gizi mi instan per 100 gram: energi 440 kkal, protein 10,2 g, lemak 17,6 g, '
        'karbohidrat 60,3 g, serat 2,9 g, gula 2,0 g, natrium 1855 mg.';
    final line = compareWithNeeds('Kandungan gizi mi instan', mi, n)!;
    expect(line, contains('100 gram mi instan memenuhi sekitar 24% energi'));
    expect(line, contains('93% batas garam'));
    expect(line, contains('garam-nya tinggi'));
  });
}
