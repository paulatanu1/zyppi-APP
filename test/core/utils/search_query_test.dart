import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/utils/search_query.dart';

void main() {
  test('matches word prefixes so search works while typing', () {
    expect(prefixTsQuery('mil'), 'mil:*');
    expect(prefixTsQuery('Brown  Br'), 'brown:* & br:*');
  });

  test('strips tsquery operators the user might type', () {
    expect(
      prefixTsQuery("milk & (bread) | !eggs:*"),
      'milk:* & bread:* & eggs:*',
    );
  });

  test('keeps non-Latin scripts', () {
    expect(prefixTsQuery('দুধ'), 'দুধ:*');
  });

  test('returns null when nothing searchable is left', () {
    expect(prefixTsQuery('   '), isNull);
    expect(prefixTsQuery('&|!'), isNull);
  });
}
