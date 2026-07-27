import 'package:flutter_test/flutter_test.dart';

import 'package:pythonchi/data/repositories/progress_repository.dart';

void main() {
  group('XP / Level curve', () {
    test('level 1 requires 0 accumulated xp below its own threshold', () {
      expect(levelForTotalXp(0), 1);
    });

    test('xpRequiredForLevel grows quadratically', () {
      expect(xpRequiredForLevel(1), 50);
      expect(xpRequiredForLevel(2), 200);
      expect(xpRequiredForLevel(3), 450);
    });

    test('levelForTotalXp returns the correct level at exact thresholds', () {
      expect(levelForTotalXp(199), 1);
      expect(levelForTotalXp(200), 2);
      expect(levelForTotalXp(449), 2);
      expect(levelForTotalXp(450), 3);
    });
  });
}
