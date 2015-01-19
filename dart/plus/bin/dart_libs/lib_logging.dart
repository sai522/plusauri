library plus.codegen.dart.libs.binary_search;

import "package:ebisu/ebisu_dart_meta.dart";
import "../plus_system.dart";

Library get lib => library('logging')
  ..imports = ['package:logging/logging.dart'];

get libs => [ lib ];
get testLibs => [];

updateSystem(System system) =>
  system..libraries.addAll(libs)..testLibraries.addAll(testLibs);

void main() => updateSystem(plus).generate(generateHop:false);
