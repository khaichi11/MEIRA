import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/recipes.dart';
import '../core/vocab.dart';
import '../theme.dart';
import 'widgets.dart';

/// Ringkasan resep terpilih. Ketuk untuk membuka detail.
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final m = state.currentMatch;
    if (m == null) return const SizedBox.shrink();
    final r = m.recipe;
    final nums = state.session!.numbers();
    final needed = r.items.where((i) => !i.optional && !pantry.contains(i.key)).toList();
    final seen = needed.where((i) => nums.containsKey(i.key) || m.have.contains(i.key)).length;
    final dish = state.sceneMode == 'hidangan';
    return Material(
      color: C.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showRecipe(context, state),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(dish ? 'Resep yang mirip' : 'Rekomendasi', style: T.caption),
                const SizedBox(height: 3),
                Text(r.name, style: T.headline),
                const SizedBox(height: 3),
                Text('${r.minutes} menit  ·  ${dish ? '${needed.length} bahan utama' : '$seen dari ${needed.length} bahan tersedia'}', style: T.footnote),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: C.tertiary),
          ]),
        ),
      ),
    );
  }
}

void showRecipe(BuildContext context, AppState state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Scope(state: state, child: const _RecipeSheet()),
  );
}

class _RecipeSheet extends StatelessWidget {
  const _RecipeSheet();

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final m = s.currentMatch;
    if (m == null) return const SizedBox(height: 200);
    final r = m.recipe;
    final nums = s.session!.numbers();
    final dish = s.sceneMode == 'hidangan';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .86,
      maxChildSize: .95,
      builder: (context, scroll) => ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [
        if (s.candidates.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: SegmentedButton<String>(
              segments: [for (final c in s.candidates) ButtonSegment(value: c.recipe.id, label: Text(c.recipe.name, overflow: TextOverflow.ellipsis))],
              selected: {r.id},
              onSelectionChanged: (v) => s.selectRecipe(v.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: C.surface,
                backgroundColor: C.grouped,
                side: BorderSide.none,
                textStyle: inter(13, weight: FontWeight.w500),
              ),
            ),
          ),
        Text(r.name, style: T.largeTitle),
        const SizedBox(height: 6),
        Text(r.desc, style: T.subhead),
        const SizedBox(height: 14),
        Row(children: [
          _Fact('${r.minutes}', 'menit'),
          _Fact('${r.servings}', 'porsi'),
          _Fact(r.difficulty, 'tingkat'),
        ]),
        const SizedBox(height: 26),
        Text('Bahan', style: T.title),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            for (var i = 0; i < r.items.length; i++) ...[
              _ItemRow(r.items[i], nums[r.items[i].key] ?? const [], m.have.contains(r.items[i].key) && !dish, dish, s),
              if (i < r.items.length - 1) const Padding(padding: EdgeInsets.only(left: 48), child: Divider()),
            ],
          ]),
        ),
        const SizedBox(height: 26),
        Text('Langkah', style: T.title),
        const SizedBox(height: 10),
        for (var i = 0; i < r.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 28, child: Text('${i + 1}', style: poppins(17, weight: FontWeight.w600, color: C.sage))),
              Expanded(child: Text(r.steps[i], style: T.body)),
            ]),
          ),
        if (r.tip.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: C.butter.withValues(alpha: .55), borderRadius: BorderRadius.circular(14)),
            child: Text(r.tip, style: T.callout),
          ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => s.speak('${r.name}. ${[for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join('\n')}'),
          icon: const Icon(Icons.volume_up_rounded, size: 20),
          label: const Text('Bacakan langkah'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: s.busy
              ? null
              : () {
                  Navigator.pop(context);
                  s.send(text: 'Ganti resep yang lain');
                },
          child: const Text('Cari resep lain'),
        ),
      ]),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(value, style: poppins(18, weight: FontWeight.w600)),
            Text(label, style: T.caption),
          ]),
        ),
      );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow(this.it, this.numbers, this.owned, this.dish, this.s);
  final RecipeItem it;
  final List<int> numbers;
  final bool owned;
  final bool dish;
  final AppState s;

  @override
  Widget build(BuildContext context) {
    final base = pantry.contains(it.key);
    final (icon, color, note) = numbers.isNotEmpty
        ? (Icons.check_circle_rounded, C.sage, '')
        : owned
            ? (Icons.check_circle_outline_rounded, C.sage, 'kamu punya')
            : base
                ? (Icons.circle, C.separator, 'bumbu dasar')
                : it.optional
                    ? (Icons.radio_button_unchecked, C.separator, 'opsional')
                    : dish
                        ? (Icons.radio_button_unchecked, C.tertiary, 'perkiraan')
                        : (Icons.radio_button_unchecked, C.clay, 'perlu disiapkan');
    return InkWell(
      onTap: numbers.isEmpty ? null : () => s.highlight(numbers),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Icon(icon, size: base ? 10 : 22, color: color),
          SizedBox(width: base ? 24 : 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.name, style: inter(16, weight: it.main ? FontWeight.w500 : FontWeight.w400)),
              if (it.amount.isNotEmpty) Text(it.amount, style: T.footnote),
            ]),
          ),
          if (numbers.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: [for (final n in numbers.take(4)) Padding(padding: const EdgeInsets.only(left: 3), child: NumberBadge(n))])
          else if (note.isNotEmpty)
            Text(note, style: inter(13, color: note == 'perlu disiapkan' ? C.clay : C.secondary)),
        ]),
      ),
    );
  }
}
