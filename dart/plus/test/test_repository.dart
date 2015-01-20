library plus.test.test_repository;

import 'package:unittest/unittest.dart';
// custom <additional imports>

import 'package:plus/repository.dart';
import 'package:plus/date.dart';

// end <additional imports>

// custom <library test_repository>
// end <library test_repository>
main() {
// custom <main>

  final repo = repository;
  test('did repository load - check john doe',
      () => expect(repository.people.johnDoe.birthDate, date(1965, 1, 1)));

// end <main>

}
