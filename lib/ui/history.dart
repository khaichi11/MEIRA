import 'package:flutter/material.dart';

import '../core/history.dart';
import '../theme.dart';
import 'widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onOpen});
  final void Function(String id) onOpen;

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _items = [];
  String _query = '';

  Future<void> reload() async {
    final items = await Scope.of(context).history.list();
    if (mounted) setState(() => _items = items);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reload();
  }

  String _group(DateTime t) {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(DateTime(t.year, t.month, t.day)).inDays;
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    if (days < 7) return '7 hari terakhir';
    if (days < 30) return '30 hari terakhir';
    return 'Lebih lama';
  }

  String _time(DateTime t) {
    final days = DateTime.now().difference(t).inDays;
    if (days < 1) return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
    return '${t.day}/${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final q = _query.toLowerCase();
    final items = q.isEmpty ? _items : _items.where((e) => '${e.title} ${e.last}'.toLowerCase().contains(q)).toList();
    final groups = <String, List<HistoryEntry>>{};
    for (final e in items) {
      groups.putIfAbsent(_group(e.updated), () => []).add(e);
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const LargeTitle('Riwayat'),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: TextField(
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Cari',
              prefixIcon: Icon(Icons.search_rounded, color: C.tertiary),
            ),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              children: [
                const Icon(Icons.history_rounded, size: 40, color: C.tertiary),
                const SizedBox(height: 10),
                Text(_query.isEmpty ? 'Belum ada percakapan' : 'Tidak ditemukan', style: T.subhead),
              ],
            ),
          ),
        for (final g in groups.entries)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Section(
              header: g.key,
              children: [
                for (final e in g.value)
                  Dismissible(
                    key: ValueKey(e.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: C.clay,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await s.history.delete(e.id);
                      setState(() => _items.removeWhere((x) => x.id == e.id));
                    },
                    child: Row2(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: e.hasPhoto
                              ? Image.file(s.history.thumbFile(e.id), fit: BoxFit.cover)
                              : const ColoredBox(
                                  color: C.accentTint,
                                  child: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: C.accent),
                                ),
                        ),
                      ),
                      title: e.title.isEmpty ? 'Percakapan' : e.title,
                      subtitle: e.last.isEmpty ? null : (e.last.length > 70 ? '${e.last.substring(0, 70)}…' : e.last),
                      trailing: Text(_time(e.updated), style: T.caption),
                      onTap: () => widget.onOpen(e.id),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
