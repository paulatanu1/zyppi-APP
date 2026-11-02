import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:zippy/core/favourites/data/favourites_repository_impl.dart';

void main() {
  late Directory dir;
  late HiveFavouritesRepository repository;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('favourites_test');
    Hive.init(dir.path);
    repository = HiveFavouritesRepository(await Hive.openBox('favourites'));
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('starts empty', () async {
    expect(await repository.getIds(), isEmpty);
  });

  test('adds and removes single ids', () async {
    await repository.add('p1');
    await repository.add('p2');
    await repository.add('p1'); // no duplicate
    expect(await repository.getIds(), {'p1', 'p2'});

    await repository.remove('p1');
    expect(await repository.getIds(), {'p2'});
  });

  test('watch emits on save', () async {
    final emitted = expectLater(repository.watch(), emits(anything));

    await repository.add('p1');

    await emitted;
  });
}
