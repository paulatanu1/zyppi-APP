/// Turns what the user typed into a Postgres `to_tsquery` that matches
/// word *prefixes*, so search-as-you-type works: "mil" finds "Milk",
/// "brown br" finds "Brown Bread". Returns null when nothing searchable is
/// left (only punctuation/spaces).
///
/// Only letters and digits survive, so tsquery operators typed by the user
/// (`& | ! : ( )`) can't break or alter the query.
String? prefixTsQuery(String input) {
  final terms = input
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .map(
        (t) => t.replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]', unicode: true), ''),
      )
      .where((t) => t.isNotEmpty)
      .toList();
  if (terms.isEmpty) return null;

  return terms.map((t) => '$t:*').join(' & ');
}
