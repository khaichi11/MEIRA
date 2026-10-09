import 'package:flutter/material.dart';

import 'health.dart';
import 'info.dart';
import 'recipe_book.dart';
import 'tour.dart';

/// Membuka fitur dari tombol aksi di obrolan atau dari tempat lain; kuncinya sama dengan routeLabels di tools.dart.
void openRoute(BuildContext context, String route) {
  switch (route) {
    case 'gizi' || 'puasa':
      openHealth(context);
    case 'tubuh':
      showBodyForm(context);
    case 'resep':
      openRecipeBook(context);
    case 'tur':
      showTour(context);
    case 'info':
      openInfo(context);
  }
}
