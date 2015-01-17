library plus.codegen.dart.libs.plus_system;

import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";
import 'package:quiver/iterables.dart';
import 'dart_libs/lib_date.dart' as date;
import 'dart_libs/lib_date_value.dart' as date_value;

String get rootPath {
  List parts = path.split(Platform.script.path);
  while(!parts.isEmpty && parts.last != 'plus') {
    parts.removeLast();
  }
  if(parts.isEmpty) {
    throw "Could not find root directory: plus";
  }
  return path.joinAll(parts);
}
  

System plus = system('plus')
  ..includeHop = true
  ..generatePubSpec = true
  ..rootPath = rootPath;

void main() {
  plus
    ..libraries.addAll(
        concat([
          date.libs,
          date_value.libs,
        ]))
    ..testLibraries.addAll(
        concat([
          date.testLibs,
          date_value.testLibs,
        ]))
    ..generate(generateHop : true);
}