
import 'dart:math';

import 'package:advent_of_dart/advent_of_dart_2015.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Day 03', () {
    final input = './test/2015/day_03_input.txt';
    final day03 = Day03();

    test('simulate', () {
      final result = day03.simulate('>');
      expect(result.item1, equals(Tuple2(1, 0)));
      expect(result.item2, equals({Tuple2(1, 0): 1, Tuple2(0, 0): 1}));
    });

    test('part 1', () {
      expect(day03.part1(input), completion(equals(2592)));
    });

    test('part 2', () {
      expect(day03.part2(input), completion(equals(2360)));
    });
  });
}
