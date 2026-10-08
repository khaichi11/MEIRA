import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../runtime/device.dart';
import '../runtime/models.dart';
import '../theme.dart';
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

  Future<void> _eyesUrl(AppState s) async {
    final p = await SharedPreferences.getInstance();
    final ctl = TextEditingController(text: p.getString('eyes_base_url') ?? '');
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.bg,
        title: Text('Sumber model Mata', style: T.headline),
        content: TextField(controller: ctl, decoration: const InputDecoration(hintText: 'https://huggingface.co/akun/repo/resolve/main')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) await p.setString('eyes_base_url', ctl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final u = _usage;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 32), children: [
      const Padding(padding: EdgeInsets.only(left: 4), child: LargeTitle('Pengaturan')),
      const SizedBox(height: 8),
      Section(header: 'Suara', footer: 'Suara sistem memakai mesin TTS bawaan perangkat. Suara Piper perlu dipasang dulu di bagian Model.', children: [
        for (final (v, label) in const [('sistem', 'Suara sistem'), ('piper', 'Suara Piper')])
          Row2(title: label, onTap: () => s.setPref('tts_engine', v), trailing: s.ttsEngine == v ? const Icon(Icons.check_rounded, color: C.sageDeep) : null),
        if (s.ttsEngine == 'sistem')
          Row2(
            title: 'Pilih suara',
            subtitle: s.voiceName ?? 'Otomatis: suara Indonesia terbaik yang bisa offline',
            trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scope(state: s, child: const _VoicePicker()))),
          ),
        Row2(title: 'Bacakan jawaban', trailing: Switch(value: s.speakAnswers, onChanged: (v) => s.setPref('speak', v))),
        Row2(title: 'Percakapan suara', subtitle: 'Bicara tanpa menekan tombol; MEIRA mendengar lagi setelah menjawab', trailing: Switch(value: s.handsFree, onChanged: s.setHandsFree)),
      ]),
      Section(
        header: 'Jawaban',
        footer: 'Ringkas: rekomendasi dan langkah diambil langsung dari buku resep, instan dan tidak mengarang. Natural: semua jawaban disusun model bahasa.',
        children: [
          for (final (v, label) in const [('ringkas', 'Ringkas'), ('natural', 'Natural')])
            Row2(title: label, onTap: () => s.setPref('answer_style', v), trailing: s.answerStyle == v ? const Icon(Icons.check_rounded, color: C.sageDeep) : null),
        ],
      ),
      Section(
        header: 'Penglihatan',
        footer: 'Mata akurat (2B) lebih jarang melewatkan bahan pada foto ramai, tetapi hampir tiga kali lebih lama. Mode otomatis memakainya bila RAM ponsel 8 GB atau lebih. '
            'Deteksi teliti membaca foto dua kali (asli dan dicerminkan) sehingga lebih sedikit bahan terlewat, dengan waktu sekitar dua kali lipat.',
        children: [
          Row2(
            title: 'Model mata',
            trailing: DropdownButton<String>(
              // pilihan yang modelnya sudah dihapus kembali ke otomatis agar menu tetap valid
              value: {'cepat': s.models.installed(eyesPack), 'akurat': s.models.installed(eyesAccuratePack)}[s.eyesChoice] ?? true ? s.eyesChoice : 'otomatis',
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(value: 'otomatis', child: Text('Otomatis')),
                if (s.models.installed(eyesPack)) const DropdownMenuItem(value: 'cepat', child: Text('Cepat (0,8B)')),
                if (s.models.installed(eyesAccuratePack)) const DropdownMenuItem(value: 'akurat', child: Text('Akurat (2B)')),
              ],
              onChanged: (v) => s.setPref('eyes_model', v ?? 'otomatis'),
            ),
          ),
          Row2(title: 'Deteksi teliti', trailing: Switch(value: s.thorough, onChanged: (v) => s.setPref('thorough', v))),
          Row2(title: 'Baca tulisan kemasan', subtitle: 'Mi instan, minyak goreng, kecap, santan, dan sejenisnya', trailing: Switch(value: s.readPackages, onChanged: (v) => s.setPref('read_packages', v))),
        ],
      ),
      Section(
        header: 'Kinerja',
        footer: 'Model mata dilatih dengan foto 768 piksel. Ukuran lebih kecil mempercepat deteksi, tetapi bahan kecil lebih mudah terlewat.',
        children: [
          Row2(
            title: 'Ukuran foto untuk model',
            trailing: DropdownButton<int>(
              value: s.imageSide,
              underline: const SizedBox.shrink(),
              items: const [DropdownMenuItem(value: 384, child: Text('384 px')), DropdownMenuItem(value: 512, child: Text('512 px')), DropdownMenuItem(value: 768, child: Text('768 px'))],
              onChanged: (v) => s.setPref('image_side', v ?? 768),
            ),
          ),
          Row2(title: 'Lepas model saat di latar belakang', subtitle: 'Menghemat RAM bila MEIRA ditinggal lebih dari 3 menit', trailing: Switch(value: s.releaseInBackground, onChanged: (v) => s.setPref('release_bg', v))),
        ],
      ),
      Section(header: 'Model di perangkat', footer: 'RAM perangkat ${Device.totalRamGb().toStringAsFixed(1)} GB. Model memakai ${_mb(s.models.usedBytes())} penyimpanan.', children: [
        for (final p in allPacks)
          Row2(
            title: p.title,
            subtitle: p.id == 'mata' && !s.models.installed(p) ? 'Belum dipasang. Sementara memakai model Otak.' : p.subtitle,
            trailing: s.models.installed(p)
                ? const Icon(Icons.check_circle, color: C.sage, size: 22)
                : _progress[p.id] != null
                    ? Text('${(_progress[p.id]! * 100).round()}%', style: T.footnote)
                    : TextButton(onPressed: () => _install(s, p), child: Text('Pasang (${p.approxMb} MB)')),
          ),
        Row2(
          title: 'Pasang dari file',
          onTap: () async {
            final res = await FilePicker.pickFiles(dialogTitle: 'Pilih file model');
            if (res.isEmpty) return;
            final copied = await s.models.import([for (final f in res) ?f.path]);
            if (context.mounted) toast(context, copied.isEmpty ? 'Tidak ada file model yang dikenali' : '${copied.length} file dipasang. Mulai ulang MEIRA.');
            setState(() {});
          },
          trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary),
        ),
        Row2(title: 'Sumber model Mata', onTap: () => _eyesUrl(s), trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary)),
      ]),
      Section(header: 'Riwayat', footer: 'Riwayat hanya disimpan di perangkat ini. Foto lama dipangkas otomatis bila melebihi 300 MB.', children: [
        Row2(title: 'Tersimpan', trailing: Text(u == null ? '' : '${u.$1} percakapan, ${_mb(u.$3)}', style: T.footnote)),
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
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: inter(16, color: C.clay))),
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
      ]),
      Section(header: 'Tentang', children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const LogoMark(size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MEIRA', style: poppins(18, weight: FontWeight.w600, spacing: 1)),
                Text('Multimodal Edge Intelligence for Recipe Assistance', style: T.footnote),
                Text('Versi 0.2.0', style: T.caption),
              ]),
            ),
          ]),
        ),
        Row2(title: 'Lisensi', onTap: () => showLicensePage(context: context, applicationName: 'MEIRA', applicationLegalese: _legal), trailing: const Icon(Icons.chevron_right_rounded, color: C.tertiary)),
      ]),
    ]);
  }
}

const _legal = 'Kode MEIRA berlisensi Apache-2.0. Buku resep, catatan dapur, dan logo: CC0. '
    'Model Qwen3.5: Apache-2.0. Whisper: MIT. sherpa-onnx: Apache-2.0, dengan espeak-ng (GPL-3.0) untuk suara Piper. '
    'llama.cpp: MIT. flutter_tts: MIT. Font Poppins dan Inter: SIL OFL 1.1. Data latih deteksi bahan: anotasi '
    'Open Images V7 dan LVIS v1 (CC BY 4.0) dengan foto berlisensi bebas; atribusi per foto ada di repo MEIRA-Before.';


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
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (voices.isEmpty)
                Text('Belum ada suara bahasa Indonesia di perangkat ini. Pasang lewat Pengaturan Android > '
                    'Bahasa dan input > Output text-to-speech > unduh data suara Indonesia.', style: T.callout),
              Section(
                footer: 'Suara yang bisa offline dan berkualitas tinggi ditaruh paling atas. Ketuk untuk memilih dan mendengar contoh.',
                children: [
                  for (final (i, v) in voices.indexed)
                    Row2(
                      title: 'Suara ${i + 1}${i == 0 ? ' (disarankan)' : ''}',
                      subtitle: '${v['name']}${v['offline'] == 'true' ? '' : ' · butuh internet'}',
                      trailing: (s.voiceName ?? voices.first['name']) == v['name'] ? const Icon(Icons.check_rounded, color: C.sageDeep) : null,
                      onTap: () async {
                        await s.setPref('voice_name', v['name']!);
                        await s.speak('Selamat datang, saya MEIRA. Pisang nomor satu sudah tersedia, Anda hanya perlu menyiapkan susu.');
                        setState(() {});
                      },
                    ),
                ],
              ),
            ]),
    );
  }
}
