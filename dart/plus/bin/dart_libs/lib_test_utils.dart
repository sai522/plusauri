library plus.codegen.dart.libs.test_utils;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

get testLibs => [ testLibrary('test_test_utils') ];
get libs => [
  library('test_utils')
  ..imports = [
  ]
];

void main() {
  plus
    ..libraries = libs
    ..testLibraries = testLibs
    ..generate( generateHop : false );
}