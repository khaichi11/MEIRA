import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../core/generated.dart';
import '../core/recipes.dart';
import '../core/vocab.dart';
import '../theme.dart';
import 'cooking.dart';
import 'widgets.dart';

/// Ringkasan resep terpilih. Ketuk untuk membuka detail.
/// Kartu resep yang bisa digeser: rekomendasi utama lalu alternatifnya. Ketuk untuk membuka detail.
class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key, required this.state});
  final AppState state;

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  final _pages = PageController(viewportFraction: .92);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final cands = s.candidates;
    if (cands.isEmpty || s.session == null) return const SizedBox.shrink();
    final nums = s.session!.numbers();
    final dish = s.sceneMode == 'hidangan';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 112,
        child: PageView.builder(
          controller: _pages,
          padEnds: false,
          itemCount: cands.length,
          onPageChanged: (i) {
            HapticFeedback.selectionClick();
            s.selectRecipe(cands[i].recipe.id);
          },
          itemBuilder: (_, i) {
            final m = cands[i];
            final r = m.recipe;
            final needed = r.items.where((it) => !it.optional && !pantry.contains(it.key)).toList();
            final seen = needed.where((it) => nums.containsKey(it.key) || m.have.contains(it.key)).length;
            return Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 6),
              child: Container(
                decoration: card(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      s.selectRecipe(r.id);
                      showRecipe(context, s);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      child: Row(children: [
                        _HaveRing(have: dish ? 0 : seen, total: needed.length),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(i == 0 ? (dish ? 'Resep yang mirip' : 'Rekomendasi') : 'Alternatif $i',
                                style: inter(12.5, weight: FontWeight.w600, color: C.accentDeep)),
                            const SizedBox(height: 2),
                            Text(r.name, style: poppins(17, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.schedule_rounded, size: 15, color: C.secondary),
                              const SizedBox(width: 4),
                              Text('${r.minutes} menit', style: T.footnote),
                              const SizedBox(width: 10),
                              const Icon(Icons.signal_cellular_alt_rounded, size: 15, color: C.secondary),
                              const SizedBox(width: 4),
                              Text(r.difficulty, style: T.footnote),
                            ]),
                          ]),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: C.tertiary),
                      ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      if (cands.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(children: [
            for (var i = 0; i < cands.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: cands[i].recipe.id == s.session!.current ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: cands[i].recipe.id == s.session!.current ? C.accent : C.separator, borderRadius: BorderRadius.circular(3)),
              ),
            const SizedBox(width: 6),
            Text('Geser untuk alternatif', style: T.caption),
          ]),
        ),
    ]);
  }
}

/// Cincin kecil: berapa bahan resep yang sudah terlihat di foto.
class _HaveRing extends StatelessWidget {
  const _HaveRing({required this.have, required this.total});
  final int have;
  final int total;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 52,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: total == 0 ? 0 : have / total,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              color: C.herb,
              backgroundColor: C.herbTint,
            ),
          ),
          Text(total == 0 ? '-' : '$have/$total', style: inter(13, weight: FontWeight.w700, color: C.herb)),
        ]),
      );
}

void showRecipe(BuildContext context, AppState state) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Scope(state: state, child: const _RecipeSheet()),
  );
}

/// Detail resep dari daftar resep di Dapur, tanpa foto.
void showRecipeDetail(BuildContext context, AppState state, Recipe recipe) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Scope(state: state, child: _RecipeSheet(recipe: recipe)),
  );
}

class _RecipeSheet extends StatelessWidget {
  const _RecipeSheet({this.recipe});
  final Recipe? recipe; // diisi bila dibuka dari daftar resep, bukan dari hasil foto

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final m = recipe == null ? s.currentMatch : null;
    if (recipe == null && m == null) return const SizedBox(height: 200);
    final r = recipe ?? m!.recipe;
    final nums = m == null ? const <String, List<int>>{} : s.session!.numbers();
    final dish = m != null && s.sceneMode == 'hidangan';
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .86,
      maxChildSize: .95,
      builder: (context, scroll) => ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [
        if (m != null && s.candidates.length > 1)
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
        if (r.tools.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Alat: ${r.tools.join(', ')}', style: T.subhead),
        ],
        const SizedBox(height: 26),
        Text('Bahan', style: T.title),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            for (var i = 0; i < r.items.length; i++) ...[
              _ItemRow(r.items[i], nums[r.items[i].key] ?? const [], (m?.have.contains(r.items[i].key) ?? false) && !dish, dish, s),
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
              SizedBox(width: 28, child: Text('${i + 1}', style: poppins(17, weight: FontWeight.w600, color: C.herb))),
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
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scope(state: s, child: CookingScreen(recipe: r))));
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('Mulai memasak'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => s.speak('${r.name}. ${[for (var i = 0; i < r.steps.length; i++) '${i + 1}. ${r.steps[i]}'].join('\n')}'),
          icon: const Icon(Icons.volume_up_rounded, size: 20),
          label: const Text('Bacakan semua langkah'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50), foregroundColor: C.accent, side: const BorderSide(color: C.separator),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
        if (m != null) ...[
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
        ],
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
        ? (Icons.check_circle_rounded, C.herb, '')
        : owned
            ? (Icons.check_circle_outline_rounded, C.herb, 'Anda miliki')
            : base
                ? (Icons.circle, C.separator, 'bumbu dasar')
                : it.optional
                    ? (Icons.radio_button_unchecked, C.separator, 'opsional')
                    : dish
                        ? (Icons.radio_button_unchecked, C.tertiary, 'perkiraan')
                        : detectableKeys.contains(it.key)
                            ? (Icons.radio_button_unchecked, C.clay, 'perlu disiapkan')
                            : (Icons.help_outline_rounded, C.tertiary, 'pastikan tersedia');
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
