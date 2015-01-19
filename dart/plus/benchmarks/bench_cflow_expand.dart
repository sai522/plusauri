library benchmarks.cflow_expand;

import 'package:benchmark_harness/benchmark_harness.dart';
// custom <additional imports>

import 'package:plus/date.dart';
import 'package:plus/date_range.dart';
import 'package:plus/date_value.dart';
import 'package:plus/finance.dart';
import 'package:plus/models/common.dart';

// end <additional imports>

class BenchCflowExpand extends BenchmarkBase {
  BenchCflowExpand() : super('CflowExpand');

  // custom <class BenchCflowExpand>

  CFlowSequenceSpec _spec;
  DateRange _specRange = new DateRange(date(2000,1,1), date(2030,1,1));
  DateRange _expandRange = new DateRange(date(2000,1,1), date(2020,1,1));
  
  void run() {
    _spec.expand(_expandRange);
  }

  static void main() {
    new BenchCflowExpand().report();
  }

  void setup() {
    _spec = new CFlowSequenceSpec()
      ..dateRange = _specRange
      ..paymentFrequency = PaymentFrequency.MONTHLY
      ..initialValue = new DateValue(date(2000,1,1), 1.0)
      ..growth = new RateCurve([ dateValue(date(1900,1,1), .03) ]);
  }


  // end <class BenchCflowExpand>
}

// custom <library bench_cflow_expand>
// end <library bench_cflow_expand>
main() {
  BenchCflowExpand.main();
}

