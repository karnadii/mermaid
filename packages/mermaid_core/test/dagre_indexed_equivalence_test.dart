// The indexed dagre pipeline (src/vendor/dagre/src/indexed_layout.dart) must
// give the same layout as the string-keyed reference code it replaces.
// Renders random diagrams with both and compares the SVG.
import 'dart:math' as math;

import 'package:mermaid_core/mermaid_core.dart';
import 'package:mermaid_core/src/vendor/dagre/src/reference_switch.dart';
import 'package:test/test.dart';

const _mermaid = Mermaid(measurer: ApproximateTextMeasurer());

String _render(String source, {required bool reference}) {
  useReferenceLayout = reference;
  try {
    return renderSceneToSvg(_mermaid.render(source));
  } catch (e) {
    return 'error: $e';
  } finally {
    useReferenceLayout = false;
  }
}

/// Random flowchart: cycles, self loops, parallel edges, edge labels,
/// nested subgraphs, edges into subgraphs, and every direction.
String _randomFlowchart(math.Random rnd, {int minNodes = 3, int spread = 40}) {
  final n = minNodes + rnd.nextInt(spread);
  final dir = const ['TD', 'LR', 'BT', 'RL'][rnd.nextInt(4)];
  final s = StringBuffer('flowchart $dir\n');
  final shapes = ['[', '(', '{', '(['];
  final closes = [']', ')', '}', '])'];
  for (var i = 0; i < n; i++) {
    final k = rnd.nextInt(shapes.length);
    s.writeln('  n$i${shapes[k]}${'w' * (1 + rnd.nextInt(12))} $i${closes[k]}');
  }
  final groups = rnd.nextInt(4);
  for (var gi = 0; gi < groups; gi++) {
    s.writeln('  subgraph g$gi[Group $gi]');
    if (rnd.nextBool()) {
      s.writeln('    direction ${const ['TB', 'LR'][rnd.nextInt(2)]}');
    }
    for (var i = 0; i < n; i++) {
      if (rnd.nextInt(groups + 3) == 0) s.writeln('    n$i');
    }
    if (gi > 0 && rnd.nextInt(3) == 0) s.writeln('    g${gi - 1}');
    s.writeln('  end');
  }
  final edges = n + rnd.nextInt(2 * n);
  for (var i = 0; i < edges; i++) {
    final a = rnd.nextInt(n);
    final b = rnd.nextInt(5) == 0 ? a : rnd.nextInt(n);
    final arrow = const ['-->', '---', '-.->', '==>', '--->'][rnd.nextInt(5)];
    final label = rnd.nextInt(3) == 0 ? '|l$i|' : '';
    final from = groups > 0 && rnd.nextInt(12) == 0
        ? 'g${rnd.nextInt(groups)}'
        : 'n$a';
    s.writeln('  $from $arrow$label n$b');
  }
  return s.toString();
}

String _randomState(math.Random rnd) {
  final n = 3 + rnd.nextInt(15);
  final s = StringBuffer('stateDiagram-v2\n  [*] --> s0\n');
  for (var i = 0; i < n; i++) {
    s.writeln('  s${rnd.nextInt(n)} --> s${rnd.nextInt(n)}: e$i');
  }
  if (rnd.nextBool()) {
    s.writeln('  state c {\n    c0 --> c1\n    c1 --> c0\n  }\n  s0 --> c');
  }
  s.writeln('  s${rnd.nextInt(n)} --> [*]');
  return s.toString();
}

String _randomClass(math.Random rnd) {
  final n = 2 + rnd.nextInt(12);
  final s = StringBuffer('classDiagram\n');
  const rels = ['<|--', '*--', 'o--', '-->', '..>', '..|>', '--'];
  for (var i = 0; i < n + rnd.nextInt(n); i++) {
    s.writeln(
      '  C${rnd.nextInt(n)} ${rels[rnd.nextInt(rels.length)]} C${rnd.nextInt(n)}',
    );
  }
  return s.toString();
}

void main() {
  final cases = <(String, String Function(math.Random), int)>[
    ('flowchart', _randomFlowchart, 1000),
    // Large graphs take many network simplex pivots.
    (
      'large flowchart',
      (r) => _randomFlowchart(r, minNodes: 80, spread: 120),
      30,
    ),
    ('state', _randomState, 200),
    ('class', _randomClass, 200),
  ];
  for (final (name, generate, count) in cases) {
    test('indexed dagre matches the reference on $count random ${name}s', () {
      final rnd = math.Random(20261017);
      var rendered = 0;
      for (var i = 0; i < count; i++) {
        final source = generate(rnd);
        final reference = _render(source, reference: true);
        final indexed = _render(source, reference: false);
        expect(indexed, reference, reason: source);
        if (!reference.startsWith('error:')) rendered++;
      }
      // Guards against a generator that only produces invalid sources.
      expect(rendered, greaterThan(count * 9 ~/ 10));
    });
  }
}
