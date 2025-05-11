
import 'dart:math';

import 'package:advent_of_dart/advent_of_dart_2015.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Day 06', () {
    final input = './test/2015/day_06_input.txt';
    final day06 = Day06();

    test('turn on 0,0 through 999,999', () {
      expect(day06.process(['turn on 0,0 through 999,999']), equals(1000000));
    });

    test('toggle 0,0 through 999,0', () {
      expect(
          day06.process(
              ['turn on 0,0 through 999,999', 'toggle 0,0 through 999,0']),
          equals(999000));
    });

    test('turn off 499,499 through 500,500', () {
      expect(
          day06.process([
            'turn on 0,0 through 999,999',
            'turn off 499,499 through 500,500'
          ]),
          equals(999996));
    });

    test('part 1', () {
      expect(day06.processFile(input), completion(equals(569999)));
    });

    test('part 2', () {
      expect(
          day06.processFile(input, levels: true), completion(equals(569999)));
    });
  });
}
