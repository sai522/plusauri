library plus.bin.dart_libs.test_utils;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

get testLibs => [ testLibrary('test_test_utils') ];
get libs => [
  library('test_utils')
  ..imports = [
  ]
];

updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
