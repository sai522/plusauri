library plus.test_utils;

// custom <additional imports>
// end <additional imports>

// custom <library test_utils>

bool closeEnough(double d1, double d2, [double tolerance = 0.00001]) =>
    (d1 - d2).abs() < tolerance;

// end <library test_utils>
