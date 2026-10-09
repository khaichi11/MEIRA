import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../theme.dart';
import 'cooking_loader.dart';
import 'widgets.dart';

/// Pembuka dan perkenalan dalam satu gerakan:
/// 0. "Halo!" muncul huruf demi huruf di layar putih, lalu lingkaran hijau melebar dari tengah menutupnya;
/// 1. layar hijau tiba-tiba berlubang di tengah, wajan muncul di lubang itu, lalu lubang melebar sampai layar putih;
/// 2. saat nama panggilan diminta, wajan turun keluar layar dan kotak hijau turun dari atas membawa sapaan;
/// 3. setelah nama diisi, lembar putih naik menutup kotak hijau dan Dapur langsung tampil.
/// Bila nama sudah tersimpan, wajan turun keluar layar dan Dapur tampil.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

const _green = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF25AE96), Color(0xFF189A84)]);

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  static const _corner = 28.0;
  static const _hole = 96.0; // jari-jari lubang pertama sebelum melebar
  static const _haloSec = 1.7, _enterSec = 2.0, _formSec = .95, _exitSec = .8; // lama tiap tahap

  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;
  double _h = 0, _e = 0, _f = 0, _x = 0; // kemajuan tahap sapaan, masuk, kolom nama, dan keluar (0 sampai 1)
  bool _formOn = false, _exitOn = false, _done = false;
  final _name = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _name.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run() {
    if (!mounted || _ticker.isActive) return;
    _last = Duration.zero;
    _ticker.start();
  }

  /// Satu langkah waktu. Selisih antarbingkai dibatasi 1/30 detik: bila ponsel sempat tersendat, misalnya saat
  /// aplikasi baru dibuka, gerakan berhenti sejenak lalu berlanjut, bukan melompat langsung ke akhir.
  void _tick(Duration elapsed) {
    final dt = math.min((elapsed - _last).inMicroseconds / 1e6, 1 / 30);
    _last = elapsed;
    var moving = false;
    if (_h < 1) {
      _h = math.min(1, _h + dt / _haloSec);
      moving = true;
    } else if (_e < 1) {
      _e = math.min(1, _e + dt / _enterSec);
      moving = true;
      if (_e == 1) _entered();
    }
    if (_formOn && _f < 1) {
      _f = math.min(1, _f + dt / _formSec);
      moving = true;
      if (_f == 1) _focus.requestFocus();
    }
    if (_exitOn && _x < 1) {
      _x = math.min(1, _x + dt / _exitSec);
      moving = true;
      if (_x == 1 && !_done) {
        _done = true;
        widget.onDone();
      }
    }
    if (!moving) _ticker.stop();
    setState(() {});
  }

  /// Lubang sudah melebar: model mulai dimuat sekarang supaya gerakan pembuka tidak terganggu.
  void _entered() {
    final s = Scope.of(context);
    if (!s.bootStarted) s.boot();
    _advance();
  }

  /// Langkah berikutnya bergantung pada keadaan aplikasi; dipanggil setiap kali keadaan berubah.
  void _advance() {
    if (!mounted || _e < 1) return;
    final s = Scope.of(context);
    if (s.phase != Phase.ready) return;
    if (s.userName == null) {
      if (!_formOn) {
        _formOn = true;
        _run();
      }
    } else if (!_exitOn && (!_formOn || _f == 1)) {
      _focus.unfocus();
      _exitOn = true;
      _run();
    }
  }

  void _save(AppState s, String name) => s.setPref('user_name', name);

  static double _seg(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);
  static double _ease(Curve c, double t) => c.transform(t);

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, box) => _stage(context, s, box.biggest)),
    );
  }

  Widget _stage(BuildContext context, AppState s, Size size) {
    final e = _e, f = _f, x = _x;
    final named = _formOn; // kolom nama sedang atau sudah tampil
    final top = MediaQuery.paddingOf(context).top;
    final headerH = top + 168;
    final center = Offset(size.width / 2, math.min(size.height * .40, 360));
    final far = math.sqrt(math.pow(size.width / 2, 2) + math.pow(math.max(center.dy, size.height - center.dy), 2));

    // 1. lubang kecil terbuka sambil sedikit memantul dan wajan muncul di dalamnya; sejenak kemudian lubang melebar
    //    sampai hijau habis, dan tulisan baru muncul setelah latar sepenuhnya putih
    final widen = _ease(Curves.easeInOutCubic, _seg(e, .42, .84));
    final hole = _hole * _ease(Curves.easeOutBack, _seg(e, .05, .25)) + (far - _hole) * widen;
    final pop = _ease(Curves.easeOutBack, _seg(e, .14, .4));
    final words = _ease(Curves.easeOutCubic, _seg(e, .84, 1));

    // 2. wajan dan tulisan memudar; kotak hijau turun dari atas; kolom nama naik dari bawah
    final fade = 1 - _ease(Curves.easeOut, named ? _seg(f, 0, .35) : _seg(x, 0, .5));
    final panel = _ease(Curves.easeOutCubic, _seg(f, .2, .75));
    final greet = _ease(Curves.easeOutCubic, _seg(f, .45, .85)) * (1 - _seg(x, 0, .35));
    final formIn = _ease(Curves.easeOutCubic, _seg(f, .55, 1));

    // 3. lembar putih naik menutup kotak hijau, warnanya menyatu dengan latar Dapur
    final rise = named ? _ease(Curves.easeInOutCubicEmphasized, _seg(x, .1, .9)) : 0.0;
    final formOut = _seg(x, 0, .3);
    final paper = Color.lerp(Colors.white, C.bg, named ? rise : _seg(x, .3, 1))!;

    final topGreen = _h == 1 && hole < math.sqrt(math.pow(size.width / 2, 2) + math.pow(center.dy, 2));
    final failed = s.phase == Phase.failed;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: topGreen || (panel > .25 && rise < .6) ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: paper)),
          // pemanasan: wajan dan teks digambar samar di balik hijau sebelum animasi mulai, supaya bingkai pertamanya
          // tidak tersendat saat shader dan huruf disiapkan
          if (e < .05)
            Positioned.fromRect(
              rect: Rect.fromCenter(center: center, width: 240, height: 440),
              child: Opacity(opacity: .01, child: Column(children: [const CookingLoader(size: 190), _status(s)])),
            ),
          // lubang di tengah hijau: lingkaran berwarna latar yang membesar (lebih ringan digambar daripada path berlubang)
          if (_h < 1) ..._halo(size, center, far),
          if (_h == 1 && hole < far) ...[
            const Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(gradient: _green)),
            ),
            if (hole > 0)
              Positioned.fromRect(
                rect: Rect.fromCircle(center: center, radius: hole),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: paper, shape: BoxShape.circle),
                ),
              ),
          ],
          if (panel > 0) ...[
            Positioned(
              left: 0,
              right: 0,
              top: -(headerH + _corner) * (1 - panel),
              height: headerH + _corner,
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: _green),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, top + 52, 28, 0),
                  child: Opacity(
                    opacity: greet,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - greet)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, selamat datang',
                            style: poppins(28, weight: FontWeight.w700, color: Colors.white, height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Text('Boleh tahu nama panggilan Anda?', style: inter(15.5, color: Colors.white.withValues(alpha: .88))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: headerH * (1 - rise),
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: paper,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(_corner * (1 - rise))),
                ),
                child: Opacity(
                  opacity: formIn * (1 - formOut),
                  child: Transform.translate(offset: Offset(0, 28 * (1 - formIn) - 24 * formOut), child: _nameForm(s)),
                ),
              ),
            ),
          ],
          if (fade > 0 && e > .14) ...[
            Positioned.fromRect(
              rect: Rect.fromCenter(center: center, width: 200, height: 200),
              child: Opacity(
                opacity: _seg(e, .14, .24) * fade,
                child: Transform.scale(
                  // muat di lubang kecil, lalu sedikit membesar bersama latar putih
                  scale: (.35 + .65 * pop) * (.79 + .21 * widen) * (.94 + .06 * fade),
                  child: failed ? const Icon(Icons.error_outline_rounded, color: C.clay, size: 72) : const CookingLoader(size: 190),
                ),
              ),
            ),
            if (words > 0)
              Positioned(
                left: 32,
                right: 32,
                top: center.dy + 116,
                child: Opacity(
                  opacity: words * fade,
                  child: Transform.translate(offset: Offset(0, 16 * (1 - words)), child: failed ? _failure(s) : _status(s)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Tahap 0: setiap huruf "Halo!" naik dan memantul kecil secara berurutan, berhenti sejenak, lalu mengecil dan memudar
  /// sementara lingkaran hijau melebar dari tengah sampai menutup layar, tepat seperti bingkai pertama tahap 1.
  List<Widget> _halo(Size size, Offset center, double far) {
    const letters = 'Halo!';
    final out = _ease(Curves.easeInCubic, _seg(_h, .6, .82));
    final grow = _ease(Curves.easeInOutCubic, _seg(_h, .62, 1));
    return [
      Positioned(
        left: 0,
        right: 0,
        top: center.dy - 40,
        child: Opacity(
          opacity: 1 - out,
          child: Transform.scale(
            scale: 1 - .18 * out,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < letters.length; i++)
                  Builder(
                    builder: (_) {
                      final t = _seg(_h, .04 + i * .07, .3 + i * .07);
                      final up = _ease(Curves.easeOutBack, t);
                      return Opacity(
                        opacity: _ease(Curves.easeOut, t),
                        child: Transform.translate(
                          offset: Offset(0, 26 * (1 - up)),
                          child: Transform.scale(
                            scale: .7 + .3 * up,
                            child: Text(
                              letters[i],
                              style: poppins(52, weight: FontWeight.w700, color: C.accentDeep, height: 1.1),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      if (grow > 0)
        Positioned.fromRect(
          rect: Rect.fromCircle(center: center, radius: far * grow),
          child: const DecoratedBox(
            decoration: BoxDecoration(gradient: _green, shape: BoxShape.circle),
          ),
        ),
    ];
  }

  Widget _status(AppState s) => Column(
    children: [
      Text('MEIRA', style: poppins(30, weight: FontWeight.w600, spacing: 2)),
      const SizedBox(height: 4),
      Text('Multimodal Edge Intelligence for Recipe Assistance', textAlign: TextAlign.center, style: T.subhead),
      const SizedBox(height: 28),
      SizedBox(
        width: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: s.bootProgress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, v, _) => LinearProgressIndicator(value: v == 0 ? null : v, minHeight: 3, color: C.accent, backgroundColor: C.accentTint),
          ),
        ),
      ),
      const SizedBox(height: 12),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(s.bootLabel, key: ValueKey(s.bootLabel), style: T.footnote),
      ),
    ],
  );

  Widget _failure(AppState s) => Column(
    children: [
      Text('MEIRA belum bisa dinyalakan.', style: T.headline),
      const SizedBox(height: 6),
      Text(s.bootError, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: T.footnote),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: s.boot,
        style: FilledButton.styleFrom(minimumSize: const Size(160, 50)),
        child: const Text('Coba lagi'),
      ),
    ],
  );

  Widget _nameForm(AppState s) {
    OutlineInputBorder edge(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            autocorrect: false,
            enableSuggestions: false,
            controller: _name,
            focusNode: _focus,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: inter(17),
            decoration: InputDecoration(
              hintText: 'Nama panggilan',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: C.secondary),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              enabledBorder: edge(C.separator),
              focusedBorder: edge(C.accent, 1.4),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (v) => v.trim().isEmpty ? null : _save(s, v),
          ),
          const SizedBox(height: 16),
          Pressable(
            child: FilledButton(onPressed: _name.text.trim().isEmpty ? null : () => _save(s, _name.text), child: const Text('Lanjut')),
          ),
          const SizedBox(height: 6),
          TextButton(onPressed: () => _save(s, ''), child: const Text('Nanti saja')),
        ],
      ),
    );
  }
}
