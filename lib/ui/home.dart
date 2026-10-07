import 'dart:io';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'history.dart';
import 'kitchen.dart';
import 'settings.dart';
import 'studio.dart';
import 'widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  final _history = GlobalKey<HistoryScreenState>();
  final _studio = GlobalKey<StudioScreenState>();

  static const _tabs = [
    (Icons.restaurant_outlined, Icons.restaurant, 'Dapur'),
    (Icons.schedule_outlined, Icons.schedule, 'Riwayat'),
    (Icons.crop_free_outlined, Icons.crop_free, 'Dataset'),
    (Icons.tune_outlined, Icons.tune, 'Pengaturan'),
  ];

  @override
  void initState() {
    super.initState();
    // MEIRA_DEMO_PHOTO=<file>: kirim satu foto otomatis setelah siap (demo dan uji tampilan di desktop)
    final demo = Platform.environment['MEIRA_DEMO_PHOTO'];
    if (demo != null && File(demo).existsSync()) {
      WidgetsBinding.instance.addPostFrameCallback((_) async => Scope.of(context).sendPhoto(await File(demo).readAsBytes()));
    }
  }

  void _go(int i) {
    setState(() => _tab = i);
    if (i == 1) _history.currentState?.reload();
    if (i == 2) _studio.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final pages = [
      KitchenScreen(onCorrect: (st) {
        _go(2);
        _studio.currentState?.open(st);
      }),
      HistoryScreen(
        key: _history,
        onOpen: (id) async {
          await s.resume(id);
          _go(0);
        },
      ),
      StudioScreen(key: _studio),
      const SettingsScreen(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = SafeArea(bottom: false, child: IndexedStack(index: _tab, children: pages));
    if (wide) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            selectedIndex: _tab,
            onDestinationSelected: _go,
            backgroundColor: C.bg,
            indicatorColor: C.sageTint,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(padding: EdgeInsets.fromLTRB(0, 18, 0, 22), child: LogoMark(size: 40)),
            selectedLabelTextStyle: inter(12, weight: FontWeight.w600, color: C.sageDeep),
            unselectedLabelTextStyle: inter(12, color: C.secondary),
            destinations: [for (final t in _tabs) NavigationRailDestination(icon: Icon(t.$1, color: C.secondary), selectedIcon: Icon(t.$2, color: C.sageDeep), label: Text(t.$3))],
          ),
          const VerticalDivider(width: .6),
          Expanded(child: body),
        ]),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.separator, width: .6))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _go,
          height: 62,
          backgroundColor: C.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [for (final t in _tabs) NavigationDestination(icon: Icon(t.$1, color: C.tertiary), selectedIcon: Icon(t.$2, color: C.sageDeep), label: t.$3)],
        ),
      ),
    );
  }
}
