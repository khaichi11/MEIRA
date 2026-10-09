import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../runtime/models.dart';
import '../theme.dart';
import 'tour.dart';
import 'widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  (int, int, int)? _usage;
  final _progress = <String, double>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Scope.of(context).history.usage().then((u) => mounted ? setState(() => _usage = u) : null);
  }

  String _mb(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(bytes > 100 * 1024 * 1024 ? 0 : 1)} MB';

  Future<void> _install(AppState s, ModelPack p) async {
    try {
      await s.models.download(p, (d, t) => setState(() => _progress[p.id] = d / t));
      if (mounted) toast(context, '${p.title} terpasang. Mulai ulang MEIRA untuk memakainya.');
    } catch (e) {
      if (mounted) toast(context, 'Gagal mengunduh ${p.title}');
    } finally {
      setState(() => _progress.remove(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final u = _usage;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 16),
      children: [
        const Padding(padding: EdgeInsets.only(left: 4), child: LargeTitle('Pengaturan')),
        const SizedBox(height: 8),
        Section(
          header: 'Profil',
          children: [
            Row2(
              title: 'Nama panggilan',
              trailing: Text(s.userName?.isNotEmpty == true ? s.userName! : 'Belum diisi', style: T.footnote),
              onTap: () async {
                final ctl = TextEditingController(text: s.userName ?? '');
                final name = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: C.bg,
                    title: Text('Nama panggilan', style: T.headline),
                    content: TextField(
                      autocorrect: false,
                      enableSuggestions: false,
                      controller: ctl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.pop(ctx, ctl.text), child: const Text('Simpan')),
                    ],
                  ),
                );
                if (name != null) await s.setPref('user_name', name);
              },
            ),
          ],
        ),
        Section(
          header: 'Suara',
          children: [
            Row2(
              title: 'Bacakan jawaban',
              trailing: Switch(value: s.speakAnswers, onChanged: (v) => s.setPref('speak', v)),
            ),
            Row2(
              title: 'Lanjut mendengar setelah menjawab',
              subtitle: 'Setelah bertanya lewat suara, mikrofon menyala lagi otomatis; ucapkan "berhenti" atau diam untuk selesai',
              trailing: Switch(value: s.autoVoiceChat, onChanged: (v) => s.setPref('auto_voice', v)),
            ),
            Row2(
              title: 'Bicara tanpa tombol',
              trailing: Switch(value: s.handsFree, onChanged: s.setHandsFree),
            ),
            Row2(
              title: 'Pilihan suara',
              subtitle: s.voiceName ?? 'Otomatis',
              trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scope(state: s, child: const _VoicePicker()),
                ),
              ),
            ),
          ],
        ),
        Section(
          header: 'Gaya jawaban',
          children: [
            for (final (v, label, sub) in const [
              ('ringkas', 'Ringkas', 'Langsung dari buku resep'),
              ('natural', 'Natural', 'Dirangkai dengan bahasa sehari-hari'),
            ])
              Row2(
                title: label,
                subtitle: sub,
                onTap: () => s.setPref('answer_style', v),
                trailing: s.answerStyle == v ? const Icon(Icons.check_rounded, color: C.accent) : null,
              ),
          ],
        ),
        Section(
          header: 'Foto',
          children: [
            Row2(
              title: 'Periksa dua kali',
              subtitle: 'Lebih teliti, sedikit lebih lama',
              trailing: Switch(value: s.thorough, onChanged: (v) => s.setPref('thorough', v)),
            ),
            Row2(
              title: 'Baca tulisan kemasan',
              trailing: Switch(value: s.readPackages, onChanged: (v) => s.setPref('read_packages', v)),
            ),
            Row2(
              title: 'Hemat RAM saat ditinggal',
              trailing: Switch(value: s.releaseInBackground, onChanged: (v) => s.setPref('release_bg', v)),
            ),
          ],
        ),
        Section(
          header: 'Model',
          footer: 'Terpakai ${_mb(s.models.usedBytes())}',
          children: [
            for (final p in allPacks)
              Row2(
                title: p.title,
                trailing: s.models.installed(p)
                    ? const Icon(Icons.check_circle_rounded, color: C.herb, size: 22)
                    : _progress[p.id] != null
                    ? Text('${(_progress[p.id]! * 100).round()}%', style: T.footnote)
                    : TextButton(onPressed: () => _install(s, p), child: Text('Unduh ${p.approxMb} MB')),
              ),
            Row2(
              title: 'Pasang dari file',
              onTap: () async {
                final res = await FilePicker.pickFiles(dialogTitle: 'Pilih file model');
                if (res.isEmpty) return;
                final copied = await s.models.import([for (final f in res) ?f.path]);
                if (context.mounted) {
                  toast(context, copied.isEmpty ? 'Tidak ada file model yang dikenali' : '${copied.length} file dipasang. Mulai ulang MEIRA.');
                }
                setState(() {});
              },
              trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
            ),
          ],
        ),
        Section(
          header: 'Riwayat',
          footer: 'Hanya disimpan di ponsel ini.',
          children: [
            Row2(
              title: 'Tersimpan',
              trailing: Text(u == null ? '' : '${u.$1} percakapan, ${_mb(u.$3)}', style: T.footnote),
            ),
            Row2(
              title: 'Hapus semua riwayat',
              destructive: true,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: C.bg,
                    title: Text('Hapus semua riwayat?', style: T.headline),
                    content: Text('Percakapan dan foto akan dihapus dari perangkat ini.', style: T.callout),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Hapus', style: inter(16, color: C.clay)),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await s.history.clear();
                  final usage = await s.history.usage();
                  setState(() => _usage = usage);
                }
              },
            ),
          ],
        ),
        Section(
          header: 'Tentang',
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MEIRA', style: poppins(18, weight: FontWeight.w600, spacing: 1)),
                  Text('Multimodal Edge Intelligence for Recipe Assistance', style: T.footnote),
                  Text('Versi 0.2.4', style: T.caption),
                ],
              ),
            ),
            Row2(
              title: 'Tur singkat fitur',
              onTap: () => showTour(context),
              trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
            ),
            Row2(
              title: 'Lisensi',
              onTap: () => showLicensePage(context: context, applicationName: 'MEIRA', applicationLegalese: _legal),
              trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
            ),
          ],
        ),
      ],
    );
  }
}

const _legal =
    'Kode MEIRA berlisensi Apache-2.0. Buku resep, catatan dapur, dan logo: CC0. '
    'Model: Qwen3.5 (Apache-2.0), Whisper (MIT), detektor D-FINE (Apache-2.0), OCR PP-OCRv5 (Apache-2.0). '
    'Pustaka: llama.cpp (MIT), ONNX Runtime (MIT), sherpa-onnx (Apache-2.0, memuat espeak-ng GPL-3.0), flutter_tts (MIT). '
    'Font Poppins dan Inter: SIL OFL 1.1. Data latih: Open Images V7 dan LVIS v1 (anotasi CC BY 4.0). '
    'Ilustrasi di aplikasi digambar sendiri dengan kode.';

class _VoicePicker extends StatefulWidget {
  const _VoicePicker();

  @override
  State<_VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<_VoicePicker> {
  List<Map<String, String>>? _voices;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Scope.of(context).speech?.indonesianVoices().then((v) => mounted ? setState(() => _voices = v) : null);
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final voices = _voices;
    return Scaffold(
      appBar: AppBar(title: const Text('Suara')),
      body: voices == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (voices.isEmpty)
                  Text(
                    'Belum ada suara bahasa Indonesia di perangkat ini. Pasang lewat Pengaturan Android > '
                    'Bahasa dan input > Output text-to-speech > unduh data suara Indonesia.',
                    style: T.callout,
                  ),
                Section(
                  footer: 'Suara yang bisa offline dan berkualitas tinggi ditaruh paling atas. Ketuk untuk memilih dan mendengar contoh.',
                  children: [
                    for (final (i, v) in voices.indexed)
                      Row2(
                        title: 'Suara ${i + 1}${i == 0 ? ' (disarankan)' : ''}',
                        subtitle: '${v['name']}${v['offline'] == 'true' ? '' : ' · butuh internet'}',
                        trailing: (s.voiceName ?? voices.first['name']) == v['name'] ? const Icon(Icons.check_rounded, color: C.accent) : null,
                        onTap: () async {
                          await s.setPref('voice_name', v['name']!);
                          await s.speak('Selamat datang, saya MEIRA. Pisang nomor satu sudah tersedia, Anda hanya perlu menyiapkan susu.');
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
