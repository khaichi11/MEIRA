import 'package:flutter/material.dart';

import '../core/health.dart';
import '../core/recipes.dart';
import '../theme.dart';
import 'recipe.dart';
import 'widgets.dart';

/// Satu baris resep: ikon menurut jenisnya, nama, waktu, dan bahan utama. Resep yang tergolong sehat diberi tanda daun.
class RecipeRow extends StatelessWidget {
  const RecipeRow({super.key, required this.recipe, this.label});
  final Recipe recipe;
  final String? label; // keterangan kecil di atas nama, misalnya "Sarapan"

  static IconData iconFor(Recipe r) => r.tags.contains('minuman')
      ? Icons.local_cafe_outlined
      : r.tags.contains('berkuah')
      ? Icons.soup_kitchen_outlined
      : r.tags.contains('sarapan')
      ? Icons.egg_outlined
      : r.tags.contains('camilan')
      ? Icons.cookie_outlined
      : Icons.restaurant_outlined;

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final r = recipe;
    return Pressable(
      child: Material(
        color: C.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showRecipeDetail(context, s, r),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: C.accentTint, borderRadius: BorderRadius.circular(14)),
                  child: Icon(iconFor(r), color: C.accentDeep, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (label != null)
                        Text(
                          label!,
                          style: inter(12, weight: FontWeight.w600, color: C.accentDeep),
                        ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              r.name,
                              style: inter(15.5, weight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isHealthy(r)) ...[const SizedBox(width: 6), const Icon(Icons.eco_rounded, size: 15, color: C.herb)],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${r.minutes} menit  ·  ${r.items.where((i) => i.main).map((i) => i.name).join(', ')}',
                        style: T.footnote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: C.tertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Saringan buku resep, dipakai di beranda dan di layar buku resep.
final recipeFilters = <(String, bool Function(Recipe))>[
  ('Semua', (_) => true),
  ('Sehat', isHealthy),
  ('Cepat', (r) => r.minutes <= 15),
  ('Sarapan', (r) => r.tags.contains('sarapan')),
  ('Tanpa kompor', (r) => r.tags.contains('tanpa-kompor')),
  ('Minuman', (r) => r.tags.contains('minuman')),
  ('Berkuah', (r) => r.tags.contains('berkuah')),
];

void openRecipeBook(BuildContext context, {int filter = 0}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeBookScreen(filter: filter)));

/// Buku resep lengkap dengan pencarian nama dan saringan.
class RecipeBookScreen extends StatefulWidget {
  const RecipeBookScreen({super.key, this.filter = 0});
  final int filter;

  @override
  State<RecipeBookScreen> createState() => _RecipeBookScreenState();
}

class _RecipeBookScreenState extends State<RecipeBookScreen> {
  late int _filter = widget.filter;
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Scope.of(context);
    final (_, test) = recipeFilters[_filter];
    final q = _query.text.trim().toLowerCase();
    final list = s.recipes
        .where((r) => test(r) && (q.isEmpty || r.name.toLowerCase().contains(q) || r.items.any((i) => i.name.toLowerCase().contains(q))))
        .toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Kembali', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        title: const Text('Buku resep'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.paddingOf(context).bottom + 16),
        children: [
          TextField(
            controller: _query,
            autocorrect: false,
            enableSuggestions: false,
            style: T.body,
            decoration: InputDecoration(
              hintText: 'Cari resep atau bahan',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: C.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.separator),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: C.separator),
              ),
            ),
          ),
          const SizedBox(height: 12),
          RecipeFilterChips(selected: _filter, onSelected: (i) => setState(() => _filter = i)),
          const SizedBox(height: 8),
          Text('${list.length} resep', style: T.footnote),
          const SizedBox(height: 10),
          for (final (i, r) in list.indexed)
            FadeIn(
              key: ValueKey('$_filter/$q/${r.id}'),
              delay: Duration(milliseconds: 40 * (i % 8)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecipeRow(recipe: r),
              ),
            ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Text('Tidak ada resep yang cocok.', style: T.subhead, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class RecipeFilterChips extends StatelessWidget {
  const RecipeFilterChips({super.key, required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: recipeFilters.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => ChoiceChip(
        label: Text(recipeFilters[i].$1),
        selected: selected == i,
        onSelected: (_) => onSelected(i),
        showCheckmark: false,
        labelStyle: inter(14, weight: FontWeight.w500, color: selected == i ? Colors.white : C.label),
        selectedColor: C.accent,
        backgroundColor: C.surface,
        side: BorderSide(color: selected == i ? C.accent : C.separator),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
