library plus.codegen.dart.libs.binary_search;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get testLib => testLibrary('test_binary_search')
  ..imports.addAll([ 'package:plus/binary_search.dart' ]);

Library get lib => library('binary_search')
  ..imports = [ '"dart:math" as math', ];

get libs => [ lib ];
get testLibs => [ testLib ];
updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
