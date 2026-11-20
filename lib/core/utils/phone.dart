/// Indian mobile numbers: 10 digits starting 6–9 (without +91).
final _indianMobile = RegExp(r'^[6-9]\d{9}$');

bool isValidIndianMobile(String digits) => _indianMobile.hasMatch(digits);

/// `+91XXXXXXXXXX`, the form saved on the profile, for a valid 10-digit
/// number (spaces and a leading +91 / 0 are tolerated). Null otherwise.
String? toIndianE164(String input) {
  var digits = input.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.startsWith('+91')) {
    digits = digits.substring(3);
  } else if (digits.length == 11 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return isValidIndianMobile(digits) ? '+91$digits' : null;
}

/// Same check as the edit-profile screen: something@something.tld.
final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String value) => _email.hasMatch(value.trim());

/// Firebase's own minimum is 6; ask for 8 (shown on the sign-up form).
const minPasswordLength = 8;
