// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library built_collection.test.set.set_builder_test;

import 'package:built_collection/built_collection.dart';
import 'package:test/test.dart';

import '../performance.dart';

void main() {
  group('SetBuilder', () {
    test('throws on attempt to create SetBuilder<dynamic>', () {
      expect(() => new SetBuilder(), throwsA(anything));
    });

    test('allows SetBuilder<Object>', () {
      new SetBuilder<Object>();
    });

    test('throws on null add', () {
      expect(() => new SetBuilder<int>().add(null), throwsA(anything));
    });

    test('throws on null addAll', () {
      expect(
          () => new SetBuilder<int>().addAll([0, 1, null]), throwsA(anything));
    });

    test('throws on null map', () {
      expect(() => new SetBuilder<int>([0, 1, 2]).map((x) => null),
          throwsA(anything));
    });

    test('throws on null expand', () {
      expect(() => new SetBuilder<int>([0, 1, 2]).expand((x) => [x, null]),
          throwsA(anything));
    });

    test('throws on wrong type addAll', () {
      expect(() => new SetBuilder<int>().addAll(new List.from([0, 1, '0'])),
          throwsA(anything));
    });

    test('has replace method that replaces all data', () {
      expect((new SetBuilder<int>()..replace([0, 1, 2])).build(), [0, 1, 2]);
    });

    // Lazy copies.

    test('does not mutate BuiltSet following reuse of underlying Set', () {
      final set = new BuiltSet<int>([1, 2]);
      final setBuilder = set.toBuilder();
      setBuilder.add(3);
      expect(set, [1, 2]);
    });

    test('converts to BuiltSet without copying', () {
      final makeLongSetBuilder = () => new SetBuilder<int>(
          new Set<int>.from(new List<int>.generate(100000, (x) => x)));
      final longSetBuilder = makeLongSetBuilder();
      final buildLongSetBuilder = () => longSetBuilder.build();

      expectMuchFaster(buildLongSetBuilder, makeLongSetBuilder);
    });

    test('does not mutate BuiltSet following mutates after build', () {
      final setBuilder = new SetBuilder<int>([1, 2]);

      final set1 = setBuilder.build();
      expect(set1, [1, 2]);

      setBuilder.add(3);
      expect(set1, [1, 2]);
    });

    test('returns identical BuiltSet on repeated build', () {
      final setBuilder = new SetBuilder<int>([1, 2]);
      expect(setBuilder.build(), same(setBuilder.build()));
    });

    // Set.

    test('has a method like Set.add', () {
      expect((new SetBuilder<int>()..add(1)).build(), [1]);
      expect((new BuiltSet<int>().toBuilder()..add(1)).build(), [1]);
    });

    test('has a method like Set.addAll', () {
      expect((new SetBuilder<int>()..addAll([1, 2])).build(), [1, 2]);
      expect((new BuiltSet<int>().toBuilder()..addAll([1, 2])).build(), [1, 2]);
    });

    test('has a method like Set.clear', () {
      expect((new SetBuilder<int>([1, 2])..clear()).build(), []);
      expect((new BuiltSet<int>([1, 2]).toBuilder()..clear()).build(), []);
    });

    test('has a method like Set.remove that returns nothing', () {
      expect((new SetBuilder<int>([1, 2])..remove(2)).build(), [1]);
      expect((new BuiltSet<int>([1, 2]).toBuilder()..remove(2)).build(), [1]);
      expect(new SetBuilder<int>([1, 2]).remove(2), isNull);
    });

    test('has a method like Set.removeAll', () {
      expect((new SetBuilder<int>([1, 2])..removeAll([2])).build(), [1]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..removeAll([2])).build(), [1]);
    });

    test('has a method like Set.removeWhere', () {
      expect((new SetBuilder<int>([1, 2])..removeWhere((x) => x == 1)).build(),
          [2]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..removeWhere((x) => x == 1))
              .build(),
          [2]);
    });

    test('has a method like Set.retainAll', () {
      expect((new SetBuilder<int>([1, 2])..retainAll([1])).build(), [1]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..retainAll([1])).build(), [1]);
    });

    test('has a method like Set.retainWhere', () {
      expect((new SetBuilder<int>([1, 2])..retainWhere((x) => x == 1)).build(),
          [1]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..retainWhere((x) => x == 1))
              .build(),
          [1]);
    });

    // Iterable.

    test('has a method like Iterable.map that updates in place', () {
      expect((new SetBuilder<int>([1, 2])..map((x) => x + 1)).build(), [2, 3]);
      expect((new BuiltSet<int>([1, 2]).toBuilder()..map((x) => x + 1)).build(),
          [2, 3]);
    });

    test('has a method like Iterable.where that updates in place', () {
      expect((new SetBuilder<int>([1, 2])..where((x) => x == 2)).build(), [2]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..where((x) => x == 2)).build(),
          [2]);
    });

    test('has a method like Iterable.expand that updates in place', () {
      expect((new SetBuilder<int>([1, 2])..expand((x) => [x, x + 2])).build(),
          [1, 3, 2, 4]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..expand((x) => [x, x + 2]))
              .build(),
          [1, 3, 2, 4]);
    });

    test('has a method like Iterable.take that updates in place', () {
      expect((new SetBuilder<int>([1, 2])..take(1)).build(), [1]);
      expect((new BuiltSet<int>([1, 2]).toBuilder()..take(1)).build(), [1]);
    });

    test('has a method like Iterable.takeWhile that updates in place', () {
      expect(
          (new SetBuilder<int>([1, 2])..takeWhile((x) => x == 1)).build(), [1]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..takeWhile((x) => x == 1))
              .build(),
          [1]);
    });

    test('has a method like Iterable.skip that updates in place', () {
      expect((new SetBuilder<int>([1, 2])..skip(1)).build(), [2]);
      expect((new BuiltSet<int>([1, 2]).toBuilder()..skip(1)).build(), [2]);
    });

    test('has a method like Iterable.skipWhile that updates in place', () {
      expect(
          (new SetBuilder<int>([1, 2])..skipWhile((x) => x == 1)).build(), [2]);
      expect(
          (new BuiltSet<int>([1, 2]).toBuilder()..skipWhile((x) => x == 1))
              .build(),
          [2]);
    });
  });
}
