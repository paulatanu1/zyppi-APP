import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/legal/presentation/legal_markdown.dart';

void main() {
  test('splits headings, paragraphs, bullets, quotes and tables', () {
    final blocks = parseLegalBlocks('''
# Title

First line
continues here.

## 1. Section
- one **bold**
> note

| A | B |
|---|---|
| x | y |
''');
    expect(blocks.map((b) => b.kind).toList(), [
      LegalBlockKind.h1,
      LegalBlockKind.paragraph,
      LegalBlockKind.h2,
      LegalBlockKind.bullet,
      LegalBlockKind.quote,
      LegalBlockKind.tableRow,
      LegalBlockKind.tableRow,
    ]);
    expect(blocks[1].text, 'First line continues here.');
    expect(blocks[3].text, 'one **bold**');
    expect(blocks.last.text, 'x · y');
  });

  test('renders every draft in docs/legal without losing a heading', () {
    final dir = Directory('docs/legal');
    final files = dir.listSync().whereType<File>().where(
      (f) => RegExp(r'/[a-z-]+\.md$').hasMatch(f.path),
    );
    expect(files, hasLength(5));
    for (final f in files) {
      final source = f.readAsStringSync().split('\n---\n').last;
      final headings = RegExp(
        r'^#{1,3} ',
        multiLine: true,
      ).allMatches(source).length;
      final parsed = parseLegalBlocks(source).where((b) => b.isHeading);
      expect(parsed.length, headings, reason: f.path);
    }
  });
}
