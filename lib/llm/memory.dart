/// Memori percakapan bergaya "summary buffer": giliran terbaru disimpan utuh selama muat dalam
/// anggaran token; giliran lama diringkas menjadi catatan pendek supaya konteks tidak penuh
/// dan jawaban tidak terpotong.
library;

class Turn {
  Turn(this.user, this.assistant);
  final String user;
  final String assistant;

  Map<String, String> toJson() => {'u': user, 'a': assistant};
  static Turn fromJson(Map<String, dynamic> j) => Turn(j['u'] ?? '', j['a'] ?? '');
}

class ConversationMemory {
  ConversationMemory({this.budgetTokens = 1100, this.maxSummaryLines = 8});

  final int budgetTokens;
  final int maxSummaryLines;
  final List<Turn> turns = [];
  final List<String> summary = [];

  void add(String user, String assistant) {
    turns.add(Turn(_clip(user, 600), _clip(assistant, 1200)));
  }

  /// Pesan untuk LLM: ringkasan giliran lama (bila ada) lalu giliran terbaru yang muat anggaran.
  /// [count] menghitung token; default perkiraan 1 token ≈ 3,2 karakter.
  List<Map<String, String>> window({int Function(String)? count}) {
    final cnt = count ?? (String t) => (t.length / 3.2).ceil();
    final kept = <Turn>[];
    var used = 0;
    for (final t in turns.reversed) {
      final cost = cnt(t.user) + cnt(t.assistant) + 8;
      if (used + cost > budgetTokens && kept.isNotEmpty) break;
      kept.insert(0, t);
      used += cost;
    }
    final older = turns.length - kept.length;
    if (older > 0) _summarize(turns.sublist(0, older));
    return [
      if (summary.isNotEmpty) {'role': 'system', 'content': 'Ringkasan percakapan sebelumnya:\n${summary.map((l) => '- $l').join('\n')}'},
      for (final t in kept) ...[
        {'role': 'user', 'content': t.user},
        {'role': 'assistant', 'content': t.assistant},
      ],
    ];
  }

  /// Ringkasan ekstraktif tanpa biaya model: permintaan pengguna dan inti jawaban.
  void _summarize(List<Turn> older) {
    summary.clear();
    for (final t in older) {
      final first = t.assistant.split(RegExp(r'(?<=[.!?])\s')).first;
      summary.add('Pengguna: ${_clip(t.user, 90)} | MEIRA: ${_clip(first, 110)}');
    }
    if (summary.length > maxSummaryLines) summary.removeRange(0, summary.length - maxSummaryLines);
  }

  List<Map<String, String>> toJson() => [for (final t in turns) t.toJson()];

  void restore(List<dynamic>? raw) {
    turns
      ..clear()
      ..addAll([for (final j in raw ?? const []) Turn.fromJson(Map<String, dynamic>.from(j))]);
  }

  static String _clip(String s, int n) => s.length <= n ? s : '${s.substring(0, n)}…';
}
