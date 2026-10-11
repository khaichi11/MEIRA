import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meira/core/grounding.dart';
import 'package:meira/vision/detector.dart';

/// Gambar persegi satu warna di seluruh bidang.
Uint8List solid(int size, int r, int g, int b) {
  final px = Uint8List(size * size * 4);
  for (var i = 0; i < size * size; i++) {
    px.setAll(i * 4, [r, g, b, 255]);
  }
  return px;
}

void main() {
  const box = [.2, .2, .8, .8];

  test('labu kuning berkulit magenta ditandai sebagai buah naga', () {
    final magenta = solid(64, 214, 40, 140);
    expect(IngredientDetector.checkSkin(const RawBox('pumpkin', .7, box), const [], magenta, 64), 'dragon_fruit');
    final orange = solid(64, 230, 140, 30);
    expect(IngredientDetector.checkSkin(const RawBox('pumpkin', .7, box), const [], orange, 64), 'pumpkin');
  });

  test('buah naga berkulit jingga hanya diganti bila detektor juga melihat labu kuning', () {
    final orange = solid(64, 230, 140, 30);
    expect(IngredientDetector.checkSkin(const RawBox('dragon_fruit', .6, box), const [], orange, 64), 'dragon_fruit');
    expect(IngredientDetector.checkSkin(const RawBox('dragon_fruit', .6, box), const [RawBox('pumpkin', .3, box)], orange, 64), 'pumpkin');
  });

  test('satu benda hanya punya satu label', () {
    final kept = dedupe([
      Detection(key: 'dragon_fruit', label: 'buah naga', rawLabel: 'buah naga', box: const [.1, .1, .5, .5]),
      Detection(key: 'pumpkin', label: 'labu kuning', rawLabel: 'labu kuning', box: const [.12, .1, .52, .52]),
      Detection(key: 'banana', label: 'pisang', rawLabel: 'pisang', box: const [.6, .6, .9, .9]),
    ]);
    expect(kept.map((d) => d.key), ['dragon_fruit', 'banana']);
  });
}
