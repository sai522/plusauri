import "package:path/path.dart" as path;
import "dart:io";

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
  
