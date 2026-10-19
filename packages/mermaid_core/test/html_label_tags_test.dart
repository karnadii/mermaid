/// Inline HTML in the labels of diagrams that mermaid.js renders as HTML
/// labels: `<b>`/`<strong>` paint bold runs, `<i>`/`<em>` italic runs, and
/// the runs fit the shape measured for them. Diagrams that mermaid.js draws
/// as SVG text keep the tags as text.
library;

import 'package:mermaid_core/mermaid_core.dart';
import 'package:test/test.dart';

import 'support/scene.dart';

const _measurer = ApproximateTextMeasurer();
const _renderer = Mermaid(measurer: _measurer);

/// (text, weight, italic) of every painted text, in paint order.
List<(String, int, bool)> _runs(Iterable<SceneNode> nodes) => [
  for (final t in textsOf(nodes)) (t.text, t.style.fontWeight, t.style.italic),
];

SceneText _text(RenderScene scene, String text) =>
    textsOf(scene.nodes).singleWhere((t) => t.text == text);

SceneGroup _group(RenderScene scene, String id) =>
    groupsOf(scene.nodes).singleWhere((g) => g.id == id);

/// The smallest rectangle shape that contains the center of [t].
Rect _boxAround(RenderScene scene, SceneText t) {
  final rects = [
    for (final s in shapesOf(scene.nodes))
      if (s.geometry case RectGeometry(:final rect))
        if (rect.contains(t.bounds.center)) rect,
  ]..sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));
  return rects.first;
}

void _expectInside(Rect inner, Rect outer, String reason) {
  expect(inner.left, greaterThanOrEqualTo(outer.left - 0.001), reason: reason);
  expect(inner.right, lessThanOrEqualTo(outer.right + 0.001), reason: reason);
  expect(inner.top, greaterThanOrEqualTo(outer.top - 0.001), reason: reason);
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + 0.001), reason: reason);
}

/// Every painted text of [scene] that is one of [runs] lies inside the
/// rectangle that holds it, and no painted text other than [literal] shows
/// an emphasis tag.
void _expectRunsFit(
  RenderScene scene,
  List<String> runs, {
  Set<String> literal = const {},
}) {
  for (final t in textsOf(scene.nodes)) {
    if (literal.contains(t.text)) continue;
    expect(t.text, isNot(matches(RegExp(r'</?(b|i|strong|em)>'))));
  }
  for (final run in runs) {
    final t = _text(scene, run);
    _expectInside(t.bounds, _boxAround(scene, t), run);
  }
}

void main() {
  group('stateDiagram-v2', () {
    final scene = _renderer.render('''
stateDiagram-v2
  s1 : <b>Bold</b> state and <i>italic</i>
  state "<strong>Strong</strong> alias" as s2
  state "<b>Group</b> title" as Comp {
    s3 : plain <em>em</em> text
  }
  s1 --> s2 : <b>go</b> now
  s2 --> Comp
  note right of s1 : <i>note</i> text
''');

    test('state descriptions paint bold and italic runs inside the box', () {
      expect(_runs(_group(scene, 's1').children), [
        ('Bold', 700, false),
        ('state and', 400, false),
        ('italic', 400, true),
      ]);
      expect(_runs(_group(scene, 's2').children), [
        ('Strong', 700, false),
        ('alias', 400, false),
      ]);
      expect(_group(scene, 's1').semanticLabel, 'Bold state and italic');
      _expectRunsFit(scene, ['Bold', 'state and', 'italic', 'Strong', 'em']);
    });

    test('composite title, note and transition label paint runs', () {
      final title = _text(scene, 'Group');
      expect(title.style.fontWeight, 700);
      expect(_text(scene, 'title').style.fontWeight, 400);
      expect(_group(scene, 'Comp').semanticLabel, 'Group title');
      expect(_text(scene, 'note').style.italic, isTrue);
      expect(_text(scene, 'go').style.fontWeight, 700);
      expect(_text(scene, 'now').style.fontWeight, 400);
      _expectRunsFit(scene, ['Group', 'note', 'go', 'now']);
    });
  });

  group('classDiagram', () {
    final scene = _renderer.render('''
classDiagram
  class A["<b>Bold</b> <i>label</i>"]
  class B {
    +String <b>name</b>
  }
  A --> B : <i>uses</i> <b>it</b>
  note for A "<b>Note</b> text"
''');

    test('class label, note and relation label paint runs', () {
      // The class title is bold already; <i> adds italic to it.
      expect(_runs(_group(scene, 'A').children), [
        ('Bold', 700, false),
        ('label', 700, true),
      ]);
      expect(_text(scene, 'Note').style.fontWeight, 700);
      expect(_text(scene, 'uses').style.italic, isTrue);
      expect(_text(scene, 'it').style.fontWeight, 700);
      _expectRunsFit(
        scene,
        ['Bold', 'label', 'Note', 'uses', 'it'],
        literal: {'+String <b>name</b>'},
      );
    });

    test('members keep their tags as text, as mermaid.js escapes them', () {
      final member = _text(scene, '+String <b>name</b>');
      expect(member.style.fontWeight, 400);
    });
  });

  group('erDiagram', () {
    final scene = _renderer.render('''
erDiagram
  CUSTOMER["<b>Customer</b> <i>alias</i>"] {
    string name "<i>full</i> address"
  }
  CUSTOMER ||--o{ ORDER : "<b>places</b>"
''');

    test('entity alias, comment and relationship label paint runs', () {
      final header = _text(scene, 'Customer');
      expect(header.style.fontWeight, 700);
      expect(_text(scene, 'alias').style.italic, isTrue);
      expect(_text(scene, 'full').style.italic, isTrue);
      expect(_text(scene, 'address').style.italic, isFalse);
      expect(_text(scene, 'places').style.fontWeight, 700);
      expect(_group(scene, 'CUSTOMER').semanticLabel, 'Customer alias');
      _expectRunsFit(scene, ['Customer', 'alias', 'full', 'places']);
    });
  });

  group('requirementDiagram', () {
    final scene = _renderer.render('''
requirementDiagram
  requirement "<b>Bold</b> req" {
    id: 1
    text: "<i>italic</i> text"
    risk: high
    verifymethod: test
  }
  element e1 {
    type: "<b>sim</b>"
  }
  e1 - satisfies -> "<b>Bold</b> req"
''');

    test('name and field values paint runs, quotes are not shown', () {
      expect(_text(scene, 'Bold').style.fontWeight, 700);
      expect(_text(scene, 'req').style.fontWeight, 700);
      expect(_text(scene, 'italic').style.italic, isTrue);
      expect(_text(scene, 'Text:').style.italic, isFalse);
      expect(_text(scene, 'sim').style.fontWeight, 700);
      expect(textsOf(scene.nodes).where((t) => t.text.contains('"')), isEmpty);
      _expectRunsFit(scene, ['Bold', 'req', 'italic', 'sim']);
    });
  });

  group('block-beta', () {
    final scene = _renderer.render('''
block-beta
  columns 2
  a["<b>Bold</b> block"] b["<i>italic</i> block"]
  a -- "<b>edge</b>" --> b
''');

    test('block and edge labels paint runs', () {
      expect(_runs(_group(scene, 'a').children), [
        ('Bold', 700, false),
        ('block', 400, false),
      ]);
      expect(_runs(_group(scene, 'b').children), [
        ('italic', 400, true),
        ('block', 400, false),
      ]);
      expect(_group(scene, 'a').semanticLabel, 'Bold block');
      expect(_text(scene, 'edge').style.fontWeight, 700);
      _expectRunsFit(scene, ['Bold', 'italic']);
    });
  });

  group('mindmap', () {
    final scene = _renderer.render('''
mindmap
  root((Root idea))
    A[<i>italic</i> child]
    B(<b>bold</b> and <i>it</i>)
''');

    test('node text paints runs inside the node', () {
      expect(_text(scene, 'italic').style.italic, isTrue);
      expect(_text(scene, 'child').style.italic, isFalse);
      expect(_text(scene, 'bold').style.fontWeight, 700);
      expect(_text(scene, 'it').style.italic, isTrue);
      expect(_group(scene, 'mind_bold and it').semanticLabel, 'bold and it');
      _expectRunsFit(scene, ['italic', 'child']);
    });
  });

  group('kanban', () {
    final scene = _renderer.render('''
kanban
  todo[Todo <i>column</i>]
    t1[<b>Fix</b> the <i>bug</i>]
  t1@{ assigned: '<b>knsv</b>' }
''');

    test('section, card title and assigned label paint runs', () {
      expect(_text(scene, 'column').style.italic, isTrue);
      expect(_text(scene, 'Fix').style.fontWeight, 700);
      expect(_text(scene, 'the').style.fontWeight, 400);
      expect(_text(scene, 'bug').style.italic, isTrue);
      final assigned = _text(scene, 'knsv');
      expect(assigned.style.fontWeight, 700);
      // Right-aligned on the card, like the plain assigned label.
      final card = _boxAround(scene, assigned);
      expect(assigned.bounds.right, closeTo(card.right - 10, 0.001));
      _expectRunsFit(scene, ['Fix', 'the', 'bug', 'knsv']);
    });
  });

  test('a long rich state label wraps at the 200px state label width', () {
    final scene = _renderer.render(
      'stateDiagram-v2\n'
      '  s1 : <b>Endpoint</b> receives external requests and knows about '
      'the service layer',
    );
    final texts = textsOf(_group(scene, 's1').children).toList();
    final lines = {for (final t in texts) t.bounds.top}.length;
    expect(lines, greaterThan(1));
    for (final t in texts) {
      expect(t.bounds.width, lessThanOrEqualTo(200));
    }
    _expectRunsFit(scene, [for (final t in texts) t.text]);
  });

  test('sequence messages keep tags as text, as mermaid.js draws SVG text', () {
    final scene = _renderer.render('sequenceDiagram\n  A->>B: <b>call</b>\n');
    expect(_text(scene, '<b>call</b>').style.fontWeight, 400);
  });

  group('SVG output', () {
    /// The `<text>` elements inside the `<g id="[id]" ...>` of [svg].
    List<String> textElementsOf(String svg, String id) {
      final start = svg.indexOf('<g id="$id"');
      expect(start, isNot(-1), reason: id);
      final end = svg.indexOf('</g>', start);
      return [
        for (final m in RegExp(
          r'<text[^>]*>.*?</text>',
        ).allMatches(svg.substring(start, end)))
          m[0]!,
      ];
    }

    /// (weight, italic, content) of each `<tspan>` in [text].
    List<(String?, bool, String)> tspans(String text) => [
      for (final m in RegExp(r'<tspan([^>]*)>([^<]*)</tspan>').allMatches(text))
        (
          RegExp(r'font-weight="(\d+)"').firstMatch(m[1]!)?[1],
          m[1]!.contains('font-style="italic"'),
          m[2]!,
        ),
    ];

    test('a styled line is one <text> with a tspan per run and its spaces', () {
      final svg = renderSceneToSvg(
        _renderer.render(
          'stateDiagram-v2\n  s1 : <b>Bold</b> state and <i>italic</i>\n',
        ),
      );
      final texts = textElementsOf(svg, 's1');
      expect(texts, hasLength(1));
      final text = texts.single;
      // The browser places the runs: one anchor for the line, spaces kept.
      expect(text, contains('xml:space="preserve"'));
      expect(text, contains('text-anchor="middle"'));
      expect(tspans(text), [
        ('700', false, 'Bold'),
        (null, false, ' state and '),
        (null, true, 'italic'),
      ]);
      expect(RegExp(r' x="').allMatches(text), hasLength(1));
    });

    test('each line of a multi-line styled label is one <text>', () {
      final svg = renderSceneToSvg(
        _renderer.render(
          'flowchart TD\n'
          '  E["<b>Endpoint</b><br/>Receives <i>external</i> requests"]\n',
        ),
      );
      final texts = textElementsOf(svg, 'E');
      expect(texts, hasLength(2));
      expect(tspans(texts[0]), [('700', false, 'Endpoint')]);
      expect(tspans(texts[1]), [
        (null, false, 'Receives '),
        (null, true, 'external'),
        (null, false, ' requests'),
      ]);
    });

    test('a left-aligned styled label anchors its line at the start', () {
      final svg = renderSceneToSvg(
        _renderer.render('''
erDiagram
  CUSTOMER {
    string name "<i>full</i> address"
  }
'''),
      );
      final text = textElementsOf(
        svg,
        'CUSTOMER',
      ).singleWhere((t) => t.contains('xml:space'));
      expect(text, contains('text-anchor="start"'));
      expect(tspans(text), [(null, true, 'full'), (null, false, ' address')]);
    });
  });
}
