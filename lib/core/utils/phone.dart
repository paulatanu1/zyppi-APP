/// Indian mobile numbers: 10 digits starting 6–9 (without +91).
final _indianMobile = RegExp(r'^[6-9]\d{9}$');

bool isValidIndianMobile(String digits) => _indianMobile.hasMatch(digits);
