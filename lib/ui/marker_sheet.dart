import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../core/grounding.dart';
import '../core/vocab.dart';
import '../theme.dart';
import 'widgets.dart';

/// Lembar koreksi penanda: benarkan nama bahan atau hapus penanda yang salah.
Future<void> showMarkerSheet(BuildContext context, AppState s, Detection d) {
  HapticFeedback.selectionClick();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Scope(state: s, child: _MarkerSheet(d)),
  );
}

class _MarkerSheet extends StatefulWidget {
  const _MarkerSheet(this.d);
  final Detection d;

  @override
  State<_MarkerSheet> createState() => _MarkerSheetState();
}

class _MarkerSheetState extends State<_MarkerSheet> {
  String _q = '';
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final d = widget.d;
    final options = ingredients.values
        .where((i) => !i.pantry && (_q.isEmpty || i.nameId.contains(_q.toLowerCase()) || i.nameEn.contains(_q.toLowerCase())))
        .take(30)
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Marker(d.number, size: 36, active: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.label, style: T.title),
                    Text(d.packaged ? 'Dibaca dari tulisan kemasan "${d.rawLabel}"' : 'Penanda nomor ${d.number}', style: T.footnote),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!_editing) ...[
            Section(
              children: [
                Row2(
                  title: 'Sudah benar',
                  leading: const Icon(Icons.check_circle_outline_rounded, color: C.herb),
                  onTap: () => Navigator.pop(context),
                ),
                Row2(
                  title: 'Ganti nama bahan',
                  leading: const Icon(Icons.edit_outlined, color: C.accent),
                  onTap: () => setState(() => _editing = true),
                ),
                Row2(
                  title: 'Bukan bahan, hapus penanda',
                  destructive: true,
                  leading: const Icon(Icons.remove_circle_outline_rounded, color: C.clay),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await s.correctMarker(d.number, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text('Koreksi langsung memperbarui resep yang disarankan.', style: T.footnote, textAlign: TextAlign.center),
          ] else ...[
            TextField(
              autocorrect: false,
              enableSuggestions: false,
              autofocus: true,
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'Cari bahan, mis. jeruk nipis',
                prefixIcon: Icon(Icons.search_rounded, color: C.tertiary),
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .42),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final i in options)
                    ListTile(
                      title: Text(i.nameId, style: T.body),
                      subtitle: Text(i.nameEn, style: T.caption),
                      trailing: i.key == d.key ? const Icon(Icons.check_rounded, color: C.accent) : null,
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        await s.correctMarker(d.number, i.key);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
