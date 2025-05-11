
import 'dart:math';

import 'package:advent_of_dart/advent_of_dart_2015.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Day 05', () {
    final input = './test/2015/day_05_input.txt';
    final day05 = Day05();

    test('example', () {
      expect(day05.isNice('ugknbfddgicrmopn'), equals(true));
      expect(day05.isNice('aaa'), equals(true));
      expect(day05.isNice('jchzalrnumimnmhp'), equals(false));
      expect(day05.isNice('haegwjzuvuyypxyu'), equals(false));
      expect(day05.isNice('dvszwmarrgswjxmb'), equals(false));
      expect(day05.isNice('urrvucyrzzzooxhx'), equals(true));
    });

    test('part 1', () {
      expect(day05.part1(input), completion(equals(238)));
    });

    test('isReallyNice', () {
      expect(day05.isReallyNice('qjhvhtzxzqqjkmpb'), equals(true));
      expect(day05.isReallyNice('xxyxx'), equals(true));
      expect(day05.isReallyNice('uurcxstgmygtbstg'), equals(false));
      expect(day05.isReallyNice('ieodomkazucvgmuy'), equals(false));
    });

    test('part 1', () {
      expect(day05.part2(input), completion(equals(69)));
    });
  });
}
