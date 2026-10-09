import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';

import '../theme.dart';
import 'widgets.dart';

/// Jejak masak seperti kotak kontribusi GitHub: satu kotak per hari selama beberapa pekan terakhir, makin pekat makin
/// sering memasak. Kotak muncul berurutan dari pekan terlama ke hari ini.
class CookGrid extends StatefulWidget {
  const CookGrid({super.key, this.weeks = 17});
  final int weeks;

  @override
  State<CookGrid> createState() => _CookGridState();
}

class _CookGridState extends State<CookGrid> with SingleTickerProviderStateMixin {
  late final _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  static const _shades = [Color(0xFFE6ECF2), Color(0xFFBFE9DF), Color(0xFF6FCBB6), Color(0xFF1FA58E), Color(0xFF13806D)];

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  void _showDay(BuildContext context, AppState s, DateTime day, int n) {
    HapticFeedback.selectionClick();
    final names = {for (final r in s.recipes) r.id: r.name};
    final cooked = [
      for (final (t, id) in s.cooks)
        if (t.year == day.year && t.month == day.month && t.day == day.day) names[id] ?? id,
    ];
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            '${day.day} ${_months[day.month - 1]}: ${n == 0 ? 'belum ada masakan' : cooked.join(', ')}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final days = s.cookDays;
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    // kolom terakhir berisi pekan ini (Senin sampai hari ini)
    final start = end.subtract(Duration(days: (widget.weeks - 1) * 7 + (end.weekday - 1)));
    return LayoutBuilder(
      builder: (context, box) {
        final cell = ((box.maxWidth - (widget.weeks - 1) * 3) / widget.weeks).clamp(8.0, 16.0);
        return AnimatedBuilder(
          animation: _in,
          builder: (context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var w = 0; w < widget.weeks; w++)
                Column(
                  children: [
                    for (var d = 0; d < 7; d++)
                      () {
                        final day = start.add(Duration(days: w * 7 + d));
                        final future = day.isAfter(end);
                        final n = days[day] ?? 0;
                        final t = Curves.easeOutBack.transform(((_in.value * (widget.weeks + 4) - w) / 4).clamp(0.0, 1.0));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Transform.scale(
                            scale: t,
                            child: GestureDetector(
                              // ketuk kotak untuk melihat masakan hari itu
                              onTap: future ? null : () => _showDay(context, s, day, n),
                              child: Container(
                                width: cell,
                                height: cell,
                                decoration: BoxDecoration(
                                  color: future ? Colors.transparent : _shades[n.clamp(0, 4)],
                                  borderRadius: BorderRadius.circular(3),
                                  border: day == end ? Border.all(color: C.accentDeep, width: 1.2) : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Kartu jejak masak di beranda: kotak-kotak, rentetan hari, dan rekor.
class CookJourneyCard extends StatelessWidget {
  const CookJourneyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final total = s.cooks.length;
    final streak = s.streak;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Jejak masak', style: T.headline)),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Pulse(child: Icon(Icons.local_fire_department_rounded, size: 16, color: C.accentDeep)),
                      const SizedBox(width: 4),
                      Text(
                        '$streak hari',
                        style: inter(13, weight: FontWeight.w600, color: C.accentDeep),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const CookGrid(),
          const SizedBox(height: 10),
          Text(
            total == 0
                ? 'Selesaikan mode memasak atau tandai resep yang sudah dimasak, kotaknya akan terisi.'
                : '$total masakan tercatat. Rentetan terpanjang ${s.bestStreak} hari.',
            style: T.footnote,
          ),
        ],
      ),
    );
  }
}
