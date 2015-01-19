part of plus.finance;

// custom <part tvm>

double DaysPerYear = 365.242199;

double years(Date start, Date end) =>
    end.dateTime.difference(start.dateTime).inDays / DaysPerYear;

double moveValueInTime(double value, double ccRate, Date start, Date end) =>
    value * exp(ccRate * years(start, end));

double ccRate(DateValue start, DateValue end) =>
    log(end.value / start.value) / years(start.date, end.date);

double ccToAnnual(double r) => exp(r) - 1.0;

// end <part tvm>

