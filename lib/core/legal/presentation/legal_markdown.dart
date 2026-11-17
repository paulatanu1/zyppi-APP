import 'package:flutter/material.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Renders the small Markdown subset the legal documents use
/// (docs/legal): headings, paragraphs, bullets, numbered items, quotes,
/// tables and **bold**. No package needed for that much.
class LegalMarkdown extends StatelessWidget {
  const LegalMarkdown(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final z = context.z;
    final out = <Widget>[];
    for (final block in parseLegalBlocks(source)) {
      final style = switch (block.kind) {
        LegalBlockKind.h1 => t.headlineSmall,
        LegalBlockKind.h2 => t.titleLarge,
        LegalBlockKind.h3 => t.titleMedium,
        LegalBlockKind.quote => t.bodyMedium!.copyWith(color: z.ink2),
        _ => t.bodyMedium,
      };
      final text = Text.rich(_inline(block.text, style!), style: style);
      out.add(
        Padding(
          padding: EdgeInsets.only(
            top: block.isHeading ? ZSpace.x4 : 0,
            bottom: ZSpace.x2,
          ),
          child: switch (block.kind) {
            LegalBlockKind.bullet || LegalBlockKind.tableRow => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ZSpace.x5,
                  child: Text(
                    block.kind == LegalBlockKind.bullet ? '•' : '–',
                    style: style,
                  ),
                ),
                Expanded(child: text),
              ],
            ),
            LegalBlockKind.quote => Container(
              padding: const EdgeInsets.all(ZSpace.x3),
              decoration: BoxDecoration(
                color: z.brandSoft,
                borderRadius: ZRadius.all(ZRadius.input),
              ),
              child: text,
            ),
            _ => text,
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: out,
    );
  }

  /// `**bold**` spans.
  static TextSpan _inline(String text, TextStyle style) {
    final parts = text.split('**');
    return TextSpan(
      children: [
        for (var i = 0; i < parts.length; i++)
          TextSpan(
            text: parts[i],
            style: i.isOdd ? style.copyWith(fontWeight: FontWeight.w700) : null,
          ),
      ],
    );
  }
}

enum LegalBlockKind { h1, h2, h3, paragraph, bullet, quote, tableRow }

class LegalBlock {
  const LegalBlock(this.kind, this.text);

  final LegalBlockKind kind;
  final String text;

  bool get isHeading =>
      kind == LegalBlockKind.h1 ||
      kind == LegalBlockKind.h2 ||
      kind == LegalBlockKind.h3;

  @override
  String toString() => '$kind: $text';
}

/// Splits Markdown into blocks. Consecutive plain lines join into one
/// paragraph; a table's header separator row is dropped and its cells are
/// joined with " · ".
List<LegalBlock> parseLegalBlocks(String source) {
  final blocks = <LegalBlock>[];
  final para = <String>[];
  void flush() {
    if (para.isNotEmpty) {
      blocks.add(LegalBlock(LegalBlockKind.paragraph, para.join(' ')));
      para.clear();
    }
  }

  for (final raw in source.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) {
      flush();
      continue;
    }
    LegalBlock? b;
    if (line.startsWith('### ')) {
      b = LegalBlock(LegalBlockKind.h3, line.substring(4));
    } else if (line.startsWith('## ')) {
      b = LegalBlock(LegalBlockKind.h2, line.substring(3));
    } else if (line.startsWith('# ')) {
      b = LegalBlock(LegalBlockKind.h1, line.substring(2));
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      b = LegalBlock(LegalBlockKind.bullet, line.substring(2));
    } else if (line.startsWith('> ')) {
      b = LegalBlock(LegalBlockKind.quote, line.substring(2));
    } else if (line.startsWith('|')) {
      final cells = line
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.every((c) => RegExp(r'^:?-{3,}:?$').hasMatch(c))) {
        flush();
        continue;
      }
      b = LegalBlock(LegalBlockKind.tableRow, cells.join(' · '));
    }
    if (b == null) {
      para.add(line);
    } else {
      flush();
      blocks.add(b);
    }
  }
  flush();
  return blocks;
}
