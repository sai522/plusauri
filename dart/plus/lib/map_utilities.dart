library map_utilities;

// custom <additional imports>

import 'dart:math';

// end <additional imports>


// custom <library map_utilities>

_defaultMerge(v1, v2) => v1 + v2;

Map mergeMaps(final Map m1, final Map m2, [Map mergeFunction(v1, v2)]) {
  if(mergeFunction == null)
    mergeFunction = _defaultMerge;

  return mergeInto(m1, new Map.from(m2), mergeFunction);
}

Map mergeInto(final Map m1, final Map m2, [Map mergeFunction(v1, v2)]) {
  if(mergeFunction == null)
    mergeFunction = _defaultMerge;

  m1.forEach((k,v) {
    var current = m2[k];
    if(current != null) {
      m2[k] = mergeFunction(current, v);
    } else {
      m2[k] = v;
    }
  });
  return m2;
}

Map valueApply(Map m, apply(value)) {
  if(m==null) return null;
  Map result = {};
  m.forEach((k,v) => result[k] = apply(v));
  return result;
}

Map valueApplyIfNotNull(Map m, apply(value)) {
  if(m==null) return null;
  Map result = {};
  m.forEach((k,v) {
    final newValue = apply(v);
    if(newValue != null)
      result[k] = apply(v);
  });
  return result;
}

Map valueApplyFromPair(Map m, apply(key, value)) {
  if(m==null) return null;
  Map result = {};
  m.forEach((k,v) => result[k] = apply(k, v));
  return result;
}

Map keyApply(Map m, apply(key)) {
  if(m==null) return null;
  Map result = {};
  m.forEach((k,v) => result[apply(k)] = v);
  return result;
}

Map keyValueApply(Map m, keyApply(key), valueApply(value)) {
  if(m==null) return null;
  Map result = {};
  m.forEach((k,v) => result[keyApply(k)] = valueApply(v));
  return result;
}

Map filterMapByPair(Map m, filter(key, value)) {
  Map result = {};
  m.forEach((k, v) {
    if(filter(k,v)) {
      result[k] = v;
    }
  });
  return result;
}

Map filterMapByValue(Map m, filter(value)) {
  Map result = {};
  m.forEach((k, v) {
    if(filter(v)) {
      result[k] = v;
    }
  });
  return result;
}

double valueDistance(Map<Object, double> m1, Map<Object, double> m2) {
  final keys = new Set.from(m1.keys)..addAll(m2.keys);
  double sum = 0.0;
  keys.forEach((key) {
        double v1 = m1[key];
        double v2 = m2[key];
        if(v1 == null) v1 = 0.0;
        if(v2 == null) v2 = 0.0;
        final diff = v1 - v2;
        sum += diff*diff;
      });
  return sqrt(sum);
}

class _Pair {
  Object first;
  Object second;
  _Pair(this.first, this.second);
}

Iterable<Object> sortedKeysByValueCompare(Map<Object, Object> map,
    [ int compare(Object a, Object b) ]) {
  List<_Pair> pairs = new List(map.length);
  int i=0;
  map.forEach((Object k, Object v) {
    pairs[i++] = new _Pair(k, v);
  });
  pairs.sort((a, b) =>
      compare == null?
      a.second.compareTo(b.second) :
      compare(a.second, b.second));
  return pairs.map((pair) => pair.first);
}

// end <library map_utilities>
