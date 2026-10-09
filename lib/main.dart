import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'theme.dart';
import 'ui/home.dart';
import 'ui/setup.dart';
import 'ui/intro.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // tepi ke tepi: bilah status dan bilah gestur bawah transparan; setiap layar memberi jarak bawah sebesar bilah gestur
  // (MediaQuery padding), jadi bilah itu tidak menutupi tombol atau teks
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  final state = AppState();
  runApp(MeiraApp(state: state)); // boot dimulai oleh IntroScreen
}

class MeiraApp extends StatefulWidget {
  const MeiraApp({super.key, required this.state});
  final AppState state;

  @override
  State<MeiraApp> createState() => _MeiraAppState();
}

class _MeiraAppState extends State<MeiraApp> {
  bool _introDone = false; // animasi pembuka sudah selesai berpindah ke Dapur

  @override
  Widget build(BuildContext context) {
    return Scope(
      state: widget.state,
      child: MaterialApp(
        title: 'MEIRA',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: Builder(
          builder: (context) {
            final s = Scope.of(context);
            final page = switch (s.phase) {
              Phase.needsModels => const SetupScreen(key: ValueKey('setup')),
              // pembuka, nama panggilan, lalu Dapur; pertanyaan pertama langsung terlihat tanpa halaman perkenalan
              Phase.ready when s.userName != null && _introDone => const HomeShell(key: ValueKey('home')),
              _ => IntroScreen(key: const ValueKey('intro'), onDone: () => setState(() => _introDone = true)),
            };
            return AnimatedSwitcher(duration: const Duration(milliseconds: 400), switchInCurve: Curves.easeOut, child: page);
          },
        ),
      ),
    );
  }
}
