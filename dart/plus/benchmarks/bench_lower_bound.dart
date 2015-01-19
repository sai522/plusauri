library benchmarks.lower_bound;

import 'package:benchmark_harness/benchmark_harness.dart';
// custom <additional imports>

import 'dart:math';
import 'package:plus/binary_search.dart';

// end <additional imports>

class BenchLowerBound extends BenchmarkBase {
  BenchLowerBound() : super('LowerBound');

  // custom <class BenchLowerBound>

  final _random = new Random(42);
  static const _size = 25000;
  final _list = new List(_size);
  int _count = 0;

  void run() {
    for (int i = 0; i < _size; ++i) {
      final val = _list[i];
      final index = lowerBound(_list, val);
      //final index = lowerBoundCompare(_list, val, (a,b) => a.compareTo(b));
      assert(index == i);
      _count++;
    }
  }

  static void main() {
    new BenchLowerBound().report();
  }

  void setup() {
    for (int i = 0; i < _size; ++i) {
      _list[i] = _random.nextDouble();
    }
    _list.sort();
  }

  void teardown() {
    print('Ran $_count iterations');
  }

  // end <class BenchLowerBound>
}

// custom <library bench_lower_bound>
// end <library bench_lower_bound>
main() {
  BenchLowerBound.main();
}

