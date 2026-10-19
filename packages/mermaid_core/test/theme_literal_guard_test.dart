import 'dart:io';

import 'package:test/test.dart';

/// Guard: diagram renderers must not paint hardcoded colors.
///
/// Every color a diagram paints belongs to `MermaidTheme`, so a host
/// application can theme the whole renderer set from one palette. A
/// literal `Color(0x…)` in a renderer is a color the host cannot reach —
/// which is exactly the bug this guard exists to prevent: the app's
/// dark mode left the gantt excluded-day wash glaring and the C4 labels
/// unreadable because those colors never went through the theme.
///
/// The exemptions are listed with a reason, and a companion test asserts
/// every entry still matches, so the list cannot rot.
void main() {
  /// Colors a renderer is allowed to keep literal, with the reason.
  ///
  /// Keyed by `path:literal`.
  const allowed = <String, String>{
    'lib/src/diagrams/venn/venn.dart:Color(0xff800080)':
        'debug-only overlay circle (drawn when useDebugLayout is set); '
            'not part of the rendered diagram.',
    'lib/src/diagrams/venn/venn.dart:Color(0xff008080)':
        'debug-only overlay rectangle (drawn when useDebugLayout is '
            'set); not part of the rendered diagram.',
  };

  /// Matches a color literal with an explicit 0xAARRGGBB value.
  final literal = RegExp(r'Color\(\s*0x[0-9a-fA-F]{8}\s*\)');

  List<String> literalsIn(String source) => literal
      .allMatches(source)
      .map((m) => m.group(0)!.replaceAll(RegExp(r'\s'), ''))
      .toList();

  /// Every color literal in the diagram renderers, as `path:literal`.
  List<String> scan() {
    final found = <String>[];
    final root = Directory('lib/src/diagrams');
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      for (final value in literalsIn(entity.readAsStringSync())) {
        found.add('$path:$value');
      }
    }
    return found;
  }

  test('diagram renderers paint only theme colors', () {
    final violations = scan().where((entry) => !allowed.containsKey(entry));
    expect(
      violations,
      isEmpty,
      reason: 'These renderers paint a literal color, so a host cannot theme '
          'them. Add a token to MermaidTheme and read it from the theme '
          'instead.\n${violations.join('\n')}',
    );
  });

  test('every allowed literal is still load-bearing', () {
    final present = scan().toSet();
    final stale = allowed.keys.where((entry) => !present.contains(entry));
    expect(
      stale,
      isEmpty,
      reason: 'These exemptions no longer match any literal. Remove them so '
          'the guard keeps its teeth.\n${stale.join('\n')}',
    );
  });
}
