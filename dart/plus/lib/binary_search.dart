library plus.binary_search;

import 'dart:math' as math;
// custom <additional imports>

// end <additional imports>

// custom <library binary_search>

typedef CompareFunc(var a, var b);

int lowerBoundCompare(List list, key, CompareFunc comparator,
    [int startIndex = 0]) {
  int leftEnd = startIndex;
  int rightEnd = list.length;

  while (leftEnd < rightEnd) {
    int middle = leftEnd + ((rightEnd - leftEnd) >> 1);
    if (comparator(list[middle], key) < 0) {
      leftEnd = middle + 1;
    } else {
      rightEnd = middle;
    }
  }
  assert(rightEnd == leftEnd);
  return leftEnd;
}

int lowerBound(List list, key, [int startIndex = 0]) {
  int leftEnd = startIndex;
  int rightEnd = list.length;

  while (leftEnd < rightEnd) {
    int middle = leftEnd + ((rightEnd - leftEnd) >> 1);
    if (list[middle].compareTo(key) < 0) {
      leftEnd = middle + 1;
    } else {
      rightEnd = middle;
    }
  }
  assert(rightEnd == leftEnd);
  return leftEnd;
}

List merge(List l1, List l2) {
  List merged = new List.generate(l1.length + l2.length, (i) => null);
  int i = 0,
      j = 0,
      k = 0;
  while (i < l1.length && j < l2.length) {
    if (l1[i].compareTo(l2[j]) < 0) {
      merged[k++] = l1[i++];
    } else {
      merged[k++] = l2[j++];
    }
  }
  if (i == l1.length) {
    merged.setAll(k, l2.sublist(j));
  } else {
    merged.setAll(k, l1.sublist(i));
  }
  return merged;
}

// end <library binary_search>
