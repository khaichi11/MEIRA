/// Rantai jawaban: prompt sistem + memori + konteks terstruktur + dokumen RAG -> LLM (streaming)
/// -> lanjut otomatis bila terpotong -> guardrail keluaran.
library;

import '../runtime/llama.dart';

class AnswerChain {
  AnswerChain(this.llm, {this.maxTokens = 520, this.maxContinuations = 3});

  final LlmClient llm;
  final int maxTokens;
  final int maxContinuations;

  /// Mengalirkan potongan teks. Bila model berhenti karena batas token, rantai meminta lanjutan
  /// tepat dari kata terakhir sehingga jawaban tidak terpotong di tengah kalimat.
  Stream<String> run({required String system, required List<Map<String, String>> memory, required String prompt}) async* {
    final base = <Map<String, dynamic>>[
      {'role': 'system', 'content': system},
      ...memory,
      {'role': 'user', 'content': prompt},
    ];
    var text = '';
    for (var round = 0; round <= maxContinuations; round++) {
      var reason = 'stop';
      final messages = round == 0
          ? base
          : [
              ...base,
              {'role': 'assistant', 'content': text},
              {'role': 'user', 'content': 'Lanjutkan tepat dari kata terakhir. Jangan mengulang bagian sebelumnya.'},
            ];
      var chunk = '';
      await for (final tok in llm.stream(messages, maxTokens: maxTokens, onFinish: (r) => reason = r)) {
        final piece = round > 0 && chunk.isEmpty ? _joinable(text, tok) : tok;
        chunk += piece;
        yield piece;
      }
      text += chunk;
      if (reason != 'length' || chunk.trim().isEmpty) break;
    }
  }

  /// Jawaban utuh tanpa streaming (dipakai bila jawaban perlu diperiksa dulu sebelum ditampilkan).
  Future<String> complete({required String system, required String prompt, List<Map<String, String>> memory = const []}) async {
    final buf = StringBuffer();
    await for (final piece in run(system: system, memory: memory, prompt: prompt)) {
      buf.write(piece);
    }
    return buf.toString().trim();
  }

  /// Rapikan sambungan antar putaran: hindari spasi ganda atau kata yang menempel.
  static String _joinable(String before, String next) {
    if (before.isEmpty) return next;
    final endsSpace = RegExp(r'\s$').hasMatch(before);
    final startsSpace = RegExp(r'^\s').hasMatch(next);
    if (endsSpace && startsSpace) return next.trimLeft();
    if (!endsSpace && !startsSpace && RegExp(r'[A-Za-z0-9,.;:]$').hasMatch(before) && RegExp(r'^[A-Za-z0-9]').hasMatch(next)) {
      return ' $next';
    }
    return next;
  }
}
