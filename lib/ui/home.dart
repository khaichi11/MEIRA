import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../theme.dart';
import 'chat.dart';
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

class _HomeShellState extends State<HomeShell> with SingleTickerProviderStateMixin {
  // tab baru memudar masuk dari sedikit di bawah
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);
  int _tab = 0;
  final _history = GlobalKey<HistoryScreenState>();
  final _studio = GlobalKey<StudioScreenState>();

  static const _tabs = [
    (Icons.home_outlined, Icons.home_rounded, 'Dapur'),
    (Icons.history_rounded, Icons.history_rounded, 'Riwayat'),
    (Icons.collections_outlined, Icons.collections_rounded, 'Dataset'),
    (Icons.settings_outlined, Icons.settings_rounded, 'Pengaturan'),
  ];

  /// Tombol kamera di tengah bilah navigasi: pilih sumber foto, lalu kembali ke Dapur.
  Future<void> _camera(AppState s) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: false,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: _SourceTile(icon: Icons.photo_camera_rounded, label: 'Kamera', onTap: () => Navigator.pop(ctx, ImageSource.camera)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceTile(icon: Icons.image_rounded, label: 'Galeri', onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    await pickPhoto(context, s, source, onCorrect: _correct);
  }

  /// Dari layar percakapan: buka foto di tab Dataset untuk membetulkan kotak.
  void _correct(AppState st) {
    _go(2);
    _studio.currentState?.open(st);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i != _tab) _fade.forward(from: 0);
    setState(() => _tab = i);
    if (i == 1) _history.currentState?.reload();
    if (i == 2) _studio.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final pages = [
      KitchenScreen(onCorrect: _correct),
      HistoryScreen(
        key: _history,
        onOpen: (id) async {
          await s.resume(id);
          if (context.mounted) openChat(context, s, onCorrect: _correct);
        },
      ),
      StudioScreen(key: _studio),
      const SettingsScreen(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final t = CurvedAnimation(parent: _fade, curve: Curves.easeOutCubic);
    final body = SafeArea(
      bottom: false,
      child: FadeTransition(
        opacity: t,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .012), end: Offset.zero).animate(t),
          child: IndexedStack(index: _tab, children: pages),
        ),
      ),
    );
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: _go,
              backgroundColor: C.bg,
              indicatorColor: C.accentTint,
              labelType: NavigationRailLabelType.all,
              leading: const SizedBox(height: 24),
              selectedLabelTextStyle: inter(12, weight: FontWeight.w600, color: C.accent),
              unselectedLabelTextStyle: inter(12, color: C.secondary),
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(
                    icon: Icon(t.$1, color: C.secondary),
                    selectedIcon: Icon(t.$2, color: C.accent),
                    label: Text(t.$3),
                  ),
              ],
            ),
            const VerticalDivider(width: .6),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [BoxShadow(color: Color(0x261F2A44), blurRadius: 24, offset: Offset(0, 8))],
            ),
            child: Row(
              children: [
                for (var i = 0; i < 2; i++) _NavItem(tab: _tabs[i], selected: _tab == i, onTap: () => _go(i)),
                _CameraButton(onTap: s.busy ? null : () => _camera(s)),
                for (var i = 2; i < 4; i++) _NavItem(tab: _tabs[i], selected: _tab == i, onTap: () => _go(i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});
  final (IconData, IconData, String) tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: selected,
      label: tab.$3,
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, a) => FadeTransition(opacity: a, child: child),
                child: Icon(selected ? tab.$2 : tab.$1, key: ValueKey(selected), color: selected ? C.accent : C.tertiary, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 5 : 0,
              height: 5,
              decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Semantics(
      button: true,
      label: 'Foto bahan',
      child: Opacity(
        opacity: onTap == null ? .5 : 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: C.accent,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x441FA58E), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const SizedBox(width: 54, height: 54, child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 26)),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: C.surface,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: C.accentTint, shape: BoxShape.circle),
              child: Icon(icon, color: C.accent),
            ),
            const SizedBox(height: 10),
            Text(label, style: T.headline),
          ],
        ),
      ),
    ),
  );
}
