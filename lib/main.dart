import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'theme.dart';
import 'ui/home.dart';
import 'ui/onboarding.dart';
import 'ui/setup.dart';
import 'ui/splash.dart';
import 'ui/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  final state = AppState();
  runApp(MeiraApp(state: state));
  state.boot();
}

class MeiraApp extends StatefulWidget {
  const MeiraApp({super.key, required this.state});
  final AppState state;

  @override
  State<MeiraApp> createState() => _MeiraAppState();
}

class _MeiraAppState extends State<MeiraApp> {
  bool _onboarded = true;

  @override
  void initState() {
    super.initState();
    Onboarding.needed().then((need) => mounted ? setState(() => _onboarded = !need) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scope(
      state: widget.state,
      child: MaterialApp(
        title: 'MEIRA',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: Builder(builder: (context) {
          final s = Scope.of(context);
          final page = switch (s.phase) {
            Phase.needsModels => const SetupScreen(key: ValueKey('setup')),
            Phase.ready => _onboarded ? const HomeShell(key: ValueKey('home')) : Onboarding(key: const ValueKey('intro'), onDone: () => setState(() => _onboarded = true)),
            _ => const SplashScreen(key: ValueKey('splash')),
          };
          return AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: page);
        }),
      ),
    );
  }
}
