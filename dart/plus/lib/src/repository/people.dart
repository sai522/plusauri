part of plus.repository;

// custom <part people>

class _People {
  get johnDoe => (person()
    ..birthDate = date(1965, 1, 1)
    ..retirementDate = date(2025, 1, 1)
    ..deathDate = date(2030, 1, 1));

  get janeDoe => (person()
    ..birthDate = date(1970, 1, 1)
    ..retirementDate = date(2015, 1, 1)
    ..deathDate = date(2055, 1, 1));

  get all => {'johnDoe': johnDoe, 'janeDoe': janeDoe,};
}

var _people = new _People();

// end <part people>
