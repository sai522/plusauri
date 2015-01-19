library pprint;

import "dart:convert";

main() { 
  print("Main for lib pprint");

// custom <pprint main>
// end <pprint main>
}


// custom <pprint top level>

String _i = "";

String indent() {
  _i = "${_i}  ";
  return _i;
}

void outdent() {
  _i = _i.substring(0, _i.length-2);
}

String i() {
  return _i;
}

String pp(Object o) {
  try {
    return o.pp();
  } on NoSuchMethodError catch(e) {
    if(o is List) {
      print("Found a list!");
    } else if(o is Map) {
      print("Found a map!");
    }
    print("Runtimetype: ${o.runtimeType}");
    return o.toString();
  } catch(e) {
    throw e;
  }
}

String jp(dynamic item) {
  return prettyJsonMap(JSON.decode(JSON.encode(item)));
}

bool _toJsonRequired(final object) {
  if (object is num) {
    return false;
  } else if (object is bool) {
    return false;
  } else if (object == null) {
    return false;
  } else if (object is String) {
    return false;
  } else if (object is List) {
    return false;
  } else if (object is Map) {
    return false;
  }

  return true;
}

String prettyJsonMap(dynamic item, [String indent = "", bool showCount = false]) {
  List<String> result = new List<String>();
  if(item is Map) {
    result.add('{\n');
    List<String> guts = new List<String>();
    List<String> keys = new List<String>.from(item.keys);
    keys.sort();
    int count = 0;
    keys.forEach((k) {
      String countTxt = showCount? "(${++count})-":"";
      guts.add('  ${indent}$countTxt"${k}": ${prettyJsonMap(item[k], "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n$indent}');
  } else if(item is List) {
    result.add('[\n');
    List<String> guts = new List<String>();
    int count = 0;
    item.forEach((i) {
      String countTxt = showCount? "(${++count})-":"";
      guts.add('  ${indent}$countTxt${prettyJsonMap(i, "$indent  ", showCount)}');
    });
    result.add(guts.join(',\n'));
    result.add('\n${indent}]');
  } else {
    if(_toJsonRequired(item)) {
      Map map;
      try {
        map = item.toJson();
      } catch(e) {        
        print("ERROR: Caught ${e} on ${item}");
        throw e;
      }

      result.add(prettyJsonMap(map, indent, showCount));

    } else {
      result.add(JSON.encode(item));
    }
  }
  return result.join('');  
}

// end <pprint top level>
