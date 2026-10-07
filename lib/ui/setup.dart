import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../runtime/models.dart';
import '../theme.dart';
import 'widgets.dart';

/// Pemasangan model sekali jalan. Setelah selesai, MEIRA berjalan sepenuhnya tanpa internet.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _progress = <String, double>{};
  String? _error;
  bool _running = false;

  Future<void> _downloadAll(AppState s) async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      for (final p in allPacks) {
        if (s.models.installed(p)) continue;
        try {
          await s.models.download(p, (done, total) => setState(() => _progress[p.id] = (done / total).clamp(0, 1)));
        } catch (e) {
          if (p.required) rethrow; // model mata hasil fine-tune boleh menyusul
        }
      }
      await s.boot();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _import(AppState s) async {
    final res = await FilePicker.pickFiles(dialogTitle: 'Pilih file model');
    if (res.isEmpty) return;
    final copied = await s.models.import([for (final f in res) ?f.path]);
    if (!mounted) return;
    toast(context, copied.isEmpty ? 'Tidak ada file model MEIRA yang dikenali' : '${copied.length} file model dipasang');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final total = allPacks.where((p) => !s.models.installed(p)).fold<int>(0, (a, p) => a + p.approxMb);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 32, 20, 24), children: [
              const Center(child: LogoMark(size: 72)),
              const SizedBox(height: 20),
              Text('Siapkan MEIRA', textAlign: TextAlign.center, style: T.largeTitle),
              const SizedBox(height: 8),
              Text('Model AI disimpan di perangkat ini. Unduh sekali, setelah itu MEIRA bekerja tanpa internet.',
                  textAlign: TextAlign.center, style: T.subhead),
              const SizedBox(height: 28),
              Section(children: [
                for (final p in allPacks)
                  Row2(
                    title: p.title,
                    subtitle: p.subtitle,
                    trailing: s.models.installed(p)
                        ? const Icon(Icons.check_circle, color: C.sage, size: 22)
                        : _progress[p.id] != null
                            ? SizedBox(width: 46, child: Text('${(_progress[p.id]! * 100).round()}%', textAlign: TextAlign.right, style: T.footnote))
                            : Text('${p.approxMb} MB${p.required ? '' : '\nopsional'}', textAlign: TextAlign.right, style: T.caption),
                  ),
              ]),
              if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(_error!, style: inter(14, color: C.clay))),
              FilledButton(
                onPressed: _running ? null : () => _downloadAll(s),
                child: Text(_running ? 'Mengunduh…' : 'Unduh ${(total / 1024).toStringAsFixed(1)} GB'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _running ? null : () => _import(s), child: const Text('Pasang dari file di perangkat')),
              const SizedBox(height: 6),
              Text('Model "Mata" hasil fine-tune MEIRA bisa dipasang menyusul. Selama belum ada, MEIRA memakai model Otak untuk melihat.',
                  textAlign: TextAlign.center, style: T.footnote),
            ]),
          ),
        ),
      ),
    );
  }
}
