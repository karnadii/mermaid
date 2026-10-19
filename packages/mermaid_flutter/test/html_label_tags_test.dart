import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mermaid_core/mermaid_core.dart' as core;
import 'package:mermaid_flutter/mermaid_flutter.dart';

// `<b>`/`<i>` in the labels of the diagrams that mermaid.js renders as HTML
// labels are measured and painted as styled runs with the Flutter engine.
const _sources = {
  'state': '''
stateDiagram-v2
  s1 : <b>Bold</b> state and <i>italic</i>
  s1 --> s2 : <b>go</b> now
''',
  'class': '''
classDiagram
  class A["<b>Bold</b> <i>label</i>"]
  A --> B : <i>uses</i> <b>it</b>
''',
  'er': '''
erDiagram
  CUSTOMER["<b>Customer</b> <i>alias</i>"] {
    string name "<i>full</i> address"
  }
  CUSTOMER ||--o{ ORDER : "<b>places</b>"
''',
  'requirement': '''
requirementDiagram
  requirement r1 {
    id: 1
    text: "<i>italic</i> text"
  }
''',
  'block': '''
block-beta
  a["<b>Bold</b> block"] b["<i>italic</i> block"]
''',
  'mindmap': '''
mindmap
  root((Root))
    A[<i>italic</i> child]
    B(<b>bold</b> and <i>it</i>)
''',
  'kanban': '''
kanban
  todo[Todo <i>column</i>]
    t1[<b>Fix</b> the <i>bug</i>]
''',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final MapEntry(key: name, value: source) in _sources.entries) {
    test('$name: runs are styled, fit their box and paint on one line', () {
      const measurer = FlutterTextMeasurer();
      final scene = core.Mermaid(measurer: measurer).render(source);
      final texts = _texts(scene.nodes);
      expect(
        texts.map((t) => t.text),
        everyElement(isNot(matches(RegExp(r'</?[bi]>')))),
      );
      final styled = texts
          .where((t) => t.style.italic || t.style.fontWeight == 700)
          .toList();
      expect(styled.where((t) => t.style.italic), isNotEmpty);
      // Filled shapes: node boxes, label backgrounds, notes. Edges are
      // stroked only.
      final rects = [
        for (final s in _shapes(scene.nodes))
          if (s.fill != null) core.geometryBounds(s.geometry),
      ];
      for (final t in styled) {
        // The painter lays a run out at its bounds width; a run measured with
        // another style would wrap to a second line here.
        final painter = TextPainter(
          text: TextSpan(text: t.text, style: textStyleFromSpec(t.style)),
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.noScaling,
        )..layout(maxWidth: t.bounds.width + 1);
        expect(painter.computeLineMetrics(), hasLength(1), reason: t.text);
        painter.dispose();
        final box = rects
            .where((r) => r.contains(t.bounds.center))
            .reduce((a, b) => a.width * a.height < b.width * b.height ? a : b);
        expect(t.bounds.left, greaterThanOrEqualTo(box.left - 0.001));
        expect(t.bounds.right, lessThanOrEqualTo(box.right + 0.001));
        expect(t.bounds.top, greaterThanOrEqualTo(box.top - 0.001));
        expect(t.bounds.bottom, lessThanOrEqualTo(box.bottom + 0.001));
      }
    });
  }

  testWidgets('state semantic label has the text without tags', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MermaidDiagram(source: _sources['state']!, semanticNodes: true),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Bold state and italic'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('<[bi]>')), findsNothing);
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);
}

List<core.SceneText> _texts(Iterable<core.SceneNode> nodes) => [
  for (final node in nodes)
    ...switch (node) {
      core.SceneText() => [node],
      core.SceneGroup(:final children) => _texts(children),
      _ => const <core.SceneText>[],
    },
];

List<core.SceneShape> _shapes(Iterable<core.SceneNode> nodes) => [
  for (final node in nodes)
    ...switch (node) {
      core.SceneShape() => [node],
      core.SceneGroup(:final children) => _shapes(children),
      _ => const <core.SceneShape>[],
    },
];
