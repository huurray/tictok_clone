import 'package:flutter_test/flutter_test.dart';
import 'package:tiktok/core/utils/number_format.dart';

void main() {
  group('formatCount', () {
    test('values under 1000 are unchanged', () {
      expect(formatCount(0), '0');
      expect(formatCount(42), '42');
      expect(formatCount(999), '999');
    });

    test('thousands use K with one decimal, trimming .0', () {
      expect(formatCount(1000), '1K');
      expect(formatCount(1200), '1.2K');
      expect(formatCount(12300), '12.3K');
      expect(formatCount(999000), '999K');
    });

    test('millions use M', () {
      expect(formatCount(1200000), '1.2M');
      expect(formatCount(3400000), '3.4M');
    });

    test('billions use B', () {
      expect(formatCount(2000000000), '2B');
    });

    test('negative values clamp to 0', () {
      expect(formatCount(-5), '0');
    });
  });
}
