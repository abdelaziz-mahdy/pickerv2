import 'package:flutter_test/flutter_test.dart';
import 'package:pickerv2/screens/picker_screen.dart';

void main() {
  test('left-half labels of the resting wheel are flipped', () {
    // 6 slices, slice 0 under the pointer: 0, 60, 120, 180, 240, 300 degrees.
    expect(
      [for (var i = 0; i < 6; i++) labelReadsUpsideDown(i, 0, 6)],
      [false, false, false, false, true, true],
    );
  });

  test('flips follow the slice the wheel stops on', () {
    // Slice 4 under the pointer: slices 2 and 3 are now on the left.
    expect(
      [for (var i = 0; i < 6; i++) labelReadsUpsideDown(i, 4, 6)],
      [false, false, true, true, false, false],
    );
  });

  test('two slices never flip', () {
    expect(labelReadsUpsideDown(0, 0, 2), isFalse);
    expect(labelReadsUpsideDown(1, 0, 2), isFalse);
  });
}
