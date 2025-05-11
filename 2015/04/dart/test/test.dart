
import 'dart:math';

import 'package:advent_of_dart/advent_of_dart_2015.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Day 04', () {
    final day04 = Day04();

    test('example 1', () {
      final example1Key = 'abcdef';
      expect(day04.part1(example1Key), equals(609043));
    });
    test('example 2', () {
      final example1Key = 'pqrstuv';
      expect(day04.part1(example1Key), equals(1048970));
    });
    test('part 1', () {
      final example1Key = 'iwrupvqb';
      expect(day04.part1(example1Key), equals(346386));
    });
    test('part 2', () {
      final example1Key = 'iwrupvqb';
      expect(day04.part1(example1Key, 6), equals(9958218));
    });
  }, tags: 'slow');
}
