/// Wardley map (`wardley-beta`): components plotted on visibility (y) vs
/// evolution (x) axes, linked into a value chain, with optional `evolve`
/// trends, pipelines, source strategies, inertia, notes, annotations and
/// accelerators. Coordinates are stored on a 0–100 scale (upstream `toPercent`).
library;

import 'dart:math' as math;

import '../../color.dart';
import '../../config_values.dart';
import '../../detect.dart';
import '../../directives.dart';
import '../../edge_geometry.dart';
import '../../geometry.dart';
import '../../ir/scene.dart';
import '../../parse_error.dart';
import '../../text/text_measurer.dart';
import '../../text/text_style.dart';
import '../../theme/theme.dart';

final _wardleyLabelCoords = RegExp(
  r'label\s*\[\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\]',
);
final _wardleyInlineParens = RegExp(r'\(([^)]*)\)');
final _wardleyHeader = RegExp(r'^wardley(-beta)?\b');
final _wardleyHeaderPrefix = RegExp(r'^wardley(-beta)?\s*');
final _wardleyComponent = RegExp(
  r'^component\s+(.+?)\s*\[\s*([\d.]+)\s*\](.*)$',
);
final _wardleyTitle = RegExp(r'^title\s+(.+)$');
final _wardleySize = RegExp(r'^size\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\]$');
final _wardleyEvolution = RegExp(r'^evolution\s+(.+)$');
final _wardleyPipelineBound = RegExp(r'@\s*([\d.]+)\s*$');
final _wardleyXAxis = RegExp(r'^x-axis\s+(.+)$');
final _wardleyYAxis = RegExp(r'^y-axis\s+(.+)$');
final _wardleyPipeline = RegExp(r'^pipeline\s+(.+?)\s*\{$');
final _wardleyNode = RegExp(
  r'^(anchor|component)\s+(.+?)\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\](.*)$',
);
final _wardleyNote = RegExp(
  r'^note\s+(.+?)\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\]$',
);
final _wardleyAnnotations = RegExp(
  r'^annotations\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\]$',
);
final _wardleyAnnotation = RegExp(
  r'^annotation\s+(\d+)\s*,?\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\]\s*(.*)$',
);
final _wardleyAccelerator = RegExp(
  r'^(de)?accelerator\s+(.+?)\s*\[\s*([\d.]+)\s*,\s*([\d.]+)\s*\]$',
);
final _wardleyEvolve = RegExp(r'^evolve\s+(.+?)\s+([\d.]+)$');
final _wardleyLinkConnector = RegExp(
  r"(?<conn>\+'[^']*'(?:<>|<|>)|-\.->|\.-\.|-->|->|\+<>|\+>|\+<|>)",
);
final _wardleyLinkPortSuffix = RegExp(r'(\+<>|\+>|\+<)\s*$');
final _wardleyLinkLabel = RegExp(r"^\+'([^']*)'");

/// Flow direction conveyed by a link's flow port / arrow decorator.
enum WardleyFlow { forward, backward, bidirectional }

/// Source strategy decorator on a component.
enum WardleySourceStrategy { build, buy, outsource, market }

class WardleyComponent {
  WardleyComponent(
    this.name,
    this.x,
    this.y,
    this.anchor, {
    this.labelOffsetX,
    this.labelOffsetY,
    this.inertia = false,
    this.sourceStrategy,
    this.className,
  });

  /// Display label / identifier.
  final String name;

  /// Evolution, 0–100 (x).
  final double x;

  /// Visibility, 0–100 (y).
  final double y;
  final bool anchor;
  final double? labelOffsetX;
  final double? labelOffsetY;
  final bool inertia;
  final WardleySourceStrategy? sourceStrategy;

  /// 'anchor' | 'component' | 'pipeline-component' | null.
  final String? className;

  /// Evolve trend target evolution (0–100), null if none.
  double? evolveTo;

  /// True if this component is a pipeline parent.
  bool isPipelineParent = false;
}

class WardleyLink {
  WardleyLink(this.from, this.to, {this.dashed = false, this.label, this.flow});
  final String from;
  final String to;
  final bool dashed;
  final String? label;
  final WardleyFlow? flow;
}

class WardleyPipeline {
  WardleyPipeline(this.parent, this.componentIds);
  final String parent;
  final List<String> componentIds;
}

class WardleyNote {
  WardleyNote(this.text, this.x, this.y);
  final String text;
  final double x;
  final double y;
}

class WardleyAnnotation {
  WardleyAnnotation(this.number, this.x, this.y, this.text);
  final int number;
  final double x;
  final double y;
  final String? text;
}

class WardleyMarker {
  WardleyMarker(this.name, this.x, this.y);
  final String name;
  final double x;
  final double y;
}

class WardleyMap {
  const WardleyMap(
    this.components,
    this.edges,
    this.title, {
    this.pipelines = const [],
    this.notes = const [],
    this.annotations = const [],
    this.annotationsBox,
    this.accelerators = const [],
    this.deaccelerators = const [],
    this.stages,
    this.stageBoundaries,
    this.xLabel,
    this.yLabel,
    this.size,
  });
  final List<WardleyComponent> components;
  final List<WardleyLink> edges;
  final String? title;
  final List<WardleyPipeline> pipelines;
  final List<WardleyNote> notes;
  final List<WardleyAnnotation> annotations;
  final ({double x, double y})? annotationsBox;
  final List<WardleyMarker> accelerators;
  final List<WardleyMarker> deaccelerators;
  final List<String>? stages;
  final List<double>? stageBoundaries;
  final String? xLabel;
  final String? yLabel;
  final ({double width, double height})? size;
}

/// Normalize a coordinate: values <= 1 are treated as 0–1 decimals (×100),
/// otherwise used as-is (0–100). Mirrors upstream `toPercent`.
double _toPercent(double value) => value <= 1 ? value * 100 : value;

WardleyMap parseWardley(String source) {
  final text = stripMetadata(source);
  final lines = text.split('\n');
  final comps = <String, WardleyComponent>{};
  final order = <WardleyComponent>[];
  final edges = <WardleyLink>[];
  final pipelines = <WardleyPipeline>[];
  final notes = <WardleyNote>[];
  final annotations = <WardleyAnnotation>[];
  final accelerators = <WardleyMarker>[];
  final deaccelerators = <WardleyMarker>[];
  ({double x, double y})? annotationsBox;
  List<String>? stages;
  List<double>? stageBoundaries;
  String? xLabel;
  String? yLabel;
  ({double width, double height})? size;
  String? title;
  var seenHeader = false;

  // Pipeline parsing state.
  String? pipelineParent;
  List<String>? pipelineMembers;

  // Parse optional trailing `label [x, y]` and decorators from a component
  // tail. Returns (cleanedTail, labelOffsets, sourceStrategy, inertia).
  ({double? lx, double? ly, WardleySourceStrategy? strategy, bool inertia})
  parseDecorators(String tail) {
    double? lx, ly;
    WardleySourceStrategy? strategy;
    var inertia = false;

    final labelM = _wardleyLabelCoords.firstMatch(tail);
    if (labelM != null) {
      lx = double.tryParse(labelM.group(1)!);
      ly = double.tryParse(labelM.group(2)!);
    }
    for (final dm in _wardleyInlineParens.allMatches(tail)) {
      final kw = dm.group(1)!.trim().toLowerCase();
      switch (kw) {
        case 'build':
          strategy = WardleySourceStrategy.build;
        case 'buy':
          strategy = WardleySourceStrategy.buy;
        case 'outsource':
          strategy = WardleySourceStrategy.outsource;
        case 'market':
          strategy = WardleySourceStrategy.market;
        case 'inertia':
          inertia = true;
      }
    }
    return (lx: lx, ly: ly, strategy: strategy, inertia: inertia);
  }

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    final c = line.indexOf('%%');
    if (c >= 0) line = line.substring(0, c).trim();
    if (line.isEmpty) continue;
    if (!seenHeader) {
      if (!_wardleyHeader.hasMatch(line)) {
        throw MermaidParseException('expected "wardley" header', line: i + 1);
      }
      seenHeader = true;
      final rest = line.replaceFirst(_wardleyHeaderPrefix, '');
      if (rest.trim().isEmpty) continue;
      line = rest.trim();
    }

    // Inside a pipeline block.
    if (pipelineParent != null) {
      if (line == '}') {
        pipelines.add(WardleyPipeline(pipelineParent, pipelineMembers!));
        pipelineParent = null;
        pipelineMembers = null;
        continue;
      }
      final pm = _wardleyComponent.firstMatch(line);
      if (pm != null) {
        final name = unquote(pm.group(1)!);
        final ex = _toPercent(double.parse(pm.group(2)!));
        final dec = parseDecorators(pm.group(3) ?? '');
        final parentComp = comps[pipelineParent];
        final py = parentComp?.y ?? 50;
        final id = '${pipelineParent}_$name';
        final comp = WardleyComponent(
          name,
          ex,
          py,
          false,
          labelOffsetX: dec.lx,
          labelOffsetY: dec.ly,
          className: 'pipeline-component',
        );
        comps[id] = comp;
        comps.putIfAbsent(name, () => comp);
        order.add(comp);
        pipelineMembers!.add(name);
      }
      continue;
    }

    var m = _wardleyTitle.firstMatch(line);
    if (m != null) {
      title = m.group(1)!.trim();
      continue;
    }

    // size [w, h]
    m = _wardleySize.firstMatch(line);
    if (m != null) {
      size = (
        width: double.parse(m.group(1)!),
        height: double.parse(m.group(2)!),
      );
      continue;
    }

    // evolution A -> B -> C  (with optional `/ second`, `@boundary`)
    m = _wardleyEvolution.firstMatch(line);
    if (m != null) {
      final parsedStages = <String>[];
      final parsedBoundaries = <double>[];
      var anyBoundary = false;
      for (var part in m.group(1)!.split('->')) {
        part = part.trim();
        final bm = _wardleyPipelineBound.firstMatch(part);
        if (bm != null) {
          parsedBoundaries.add(double.parse(bm.group(1)!));
          anyBoundary = true;
          part = part.substring(0, bm.start).trim();
        }
        final slash = part.indexOf('/');
        if (slash >= 0) {
          part =
              '${part.substring(0, slash).trim()} / ${part.substring(slash + 1).trim()}';
        }
        parsedStages.add(part);
      }
      stages = parsedStages;
      if (anyBoundary && parsedBoundaries.length == parsedStages.length) {
        stageBoundaries = parsedBoundaries;
      }
      continue;
    }

    // x-axis / y-axis label overrides.
    m = _wardleyXAxis.firstMatch(line);
    if (m != null) {
      xLabel = m.group(1)!.trim();
      continue;
    }
    m = _wardleyYAxis.firstMatch(line);
    if (m != null) {
      yLabel = m.group(1)!.trim();
      continue;
    }

    // pipeline Parent {
    m = _wardleyPipeline.firstMatch(line);
    if (m != null) {
      pipelineParent = unquote(m.group(1)!);
      pipelineMembers = <String>[];
      comps[pipelineParent]?.isPipelineParent = true;
      continue;
    }

    // anchor / component NAME [v, e] (decorators)
    m = _wardleyNode.firstMatch(line);
    if (m != null) {
      final isAnchor = m.group(1) == 'anchor';
      final name = unquote(m.group(2)!);
      final vis = _toPercent(double.parse(m.group(3)!));
      final evo = _toPercent(double.parse(m.group(4)!));
      final dec = parseDecorators(m.group(5) ?? '');
      final comp = WardleyComponent(
        name,
        evo,
        vis,
        isAnchor,
        labelOffsetX: dec.lx,
        labelOffsetY: dec.ly,
        inertia: dec.inertia,
        sourceStrategy: dec.strategy,
        className: isAnchor ? 'anchor' : 'component',
      );
      comps[name] = comp;
      order.add(comp);
      continue;
    }

    // note "text" [v, e]
    m = _wardleyNote.firstMatch(line);
    if (m != null) {
      notes.add(
        WardleyNote(
          unquote(m.group(1)!),
          _toPercent(double.parse(m.group(3)!)),
          _toPercent(double.parse(m.group(2)!)),
        ),
      );
      continue;
    }

    // annotations [v, e]  (the box anchor)
    m = _wardleyAnnotations.firstMatch(line);
    if (m != null) {
      annotationsBox = (
        x: _toPercent(double.parse(m.group(2)!)),
        y: _toPercent(double.parse(m.group(1)!)),
      );
      continue;
    }

    // annotation N,[v, e] "text"
    m = _wardleyAnnotation.firstMatch(line);
    if (m != null) {
      final txt = m.group(4)!.trim();
      annotations.add(
        WardleyAnnotation(
          int.parse(m.group(1)!),
          _toPercent(double.parse(m.group(3)!)),
          _toPercent(double.parse(m.group(2)!)),
          txt.isEmpty ? null : unquote(txt),
        ),
      );
      continue;
    }

    // accelerator / deaccelerator NAME [v, e]
    m = _wardleyAccelerator.firstMatch(line);
    if (m != null) {
      final marker = WardleyMarker(
        unquote(m.group(2)!),
        _toPercent(double.parse(m.group(4)!)),
        _toPercent(double.parse(m.group(3)!)),
      );
      if (m.group(1) == 'de') {
        deaccelerators.add(marker);
      } else {
        accelerators.add(marker);
      }
      continue;
    }

    // evolve NAME target
    m = _wardleyEvolve.firstMatch(line);
    if (m != null) {
      comps[m.group(1)!.trim()]?.evolveTo = _toPercent(
        double.parse(m.group(2)!),
      );
      continue;
    }

    // links: from (fromPort)? (arrow)? to (toPort)? (; label)?
    //   fromPort/toPort: +<> | +> | +<        (LINK_PORT)
    //   arrow: -> | --> | -.-> | .-. | >       (ARROW / LINK_ARROW)
    //          | +'label'<> | +'label'< | +'label'>
    // The connector is the first such token after a `from` operand.
    final connector = _wardleyLinkConnector;
    if (!line.startsWith('note') && connector.hasMatch(line)) {
      final cm = connector.firstMatch(line)!;
      var from = line.substring(0, cm.start).trim();
      var conn = cm.namedGroup('conn')!;
      var rest = line.substring(cm.end).trim();
      // Optional trailing fromPort attached to `from` operand and an arrow.
      // Optional `; label`.
      String? label;
      final semi = rest.indexOf(';');
      if (semi >= 0) {
        label = rest.substring(semi + 1).trim();
        rest = rest.substring(0, semi).trim();
      }
      // A trailing toPort on the right operand.
      WardleyFlow? toFlow;
      final toPortM = _wardleyLinkPortSuffix.firstMatch(rest);
      if (toPortM != null) {
        final tp = toPortM.group(1)!;
        toFlow = tp.contains('<>')
            ? WardleyFlow.bidirectional
            : tp.contains('<')
            ? WardleyFlow.backward
            : WardleyFlow.forward;
        rest = rest.substring(0, toPortM.start).trim();
      }
      final to = rest;
      if (from.isNotEmpty && to.isNotEmpty) {
        final dashed = conn.contains('-.->') || conn.contains('.-.');
        // Inline label, e.g. +'constraint'<>
        final lblM = _wardleyLinkLabel.firstMatch(conn);
        if (lblM != null) label ??= lblM.group(1);

        WardleyFlow? flow;
        if (conn.startsWith('+')) {
          if (conn.contains('<>')) {
            flow = WardleyFlow.bidirectional;
          } else if (conn.contains('<')) {
            flow = WardleyFlow.backward;
          } else if (conn.contains('>')) {
            flow = WardleyFlow.forward;
          }
        }
        flow ??= toFlow;
        edges.add(
          WardleyLink(
            unquote(from),
            unquote(to),
            dashed: dashed,
            label: label,
            flow: flow,
          ),
        );
        continue;
      }
    }
  }
  if (!seenHeader) throw const MermaidParseException('empty wardley source');
  return WardleyMap(
    order,
    edges,
    title,
    pipelines: pipelines,
    notes: notes,
    annotations: annotations,
    annotationsBox: annotationsBox,
    accelerators: accelerators,
    deaccelerators: deaccelerators,
    stages: stages,
    stageBoundaries: stageBoundaries,
    xLabel: xLabel,
    yLabel: yLabel,
    size: size,
  );
}

// The wardley palette lives on `MermaidTheme`, so a host app can theme the
// map: `wardleyAxisColor` / `wardleyAxisTextColor` for the axes, the stage
// labels and the free-standing text (notes, annotation numbers, annotation
// box), `wardleyComponentFill` / `wardleyComponentStroke` /
// `wardleyComponentLabelColor` for the nodes, `wardleyLinkStroke` for the
// links, `wardleyEvolutionStroke` for the trends, `wardleyAnnotationStroke`
// for the annotations, `wardleyOutsourceFill` / `wardleyBuyFill` /
// `wardleyBuildFill` for the source-strategy overlays, and `canvasColor` for
// the "paper" fills painted on the canvas (market glyph, annotations,
// accelerators).

const _defaultStages = ['Genesis', 'Custom Built', 'Product', 'Commodity'];

class WardleyConfig {
  const WardleyConfig({
    this.width = 900,
    this.height = 600,
    this.padding = 48,
    this.nodeRadius = 6,
    this.nodeLabelOffset = 8,
    this.axisFontSize = 12,
    this.labelFontSize = 10,
    this.showGrid = false,
  });

  final double width;
  final double height;
  final double padding;
  final double nodeRadius;
  final double nodeLabelOffset;
  final double axisFontSize;
  final double labelFontSize;
  final bool showGrid;

  factory WardleyConfig.fromSource(String source) {
    final values = resolveDiagramConfig(source, 'wardley-beta');
    return WardleyConfig(
      width: positiveDouble(values, 'width', 900),
      height: positiveDouble(values, 'height', 600),
      padding: nonNegativeDouble(values, 'padding', 48),
      nodeRadius: nonNegativeDouble(values, 'nodeRadius', 6),
      nodeLabelOffset: nonNegativeDouble(values, 'nodeLabelOffset', 8),
      axisFontSize: nonNegativeDouble(values, 'axisFontSize', 12),
      labelFontSize: nonNegativeDouble(values, 'labelFontSize', 10),
      showGrid: boolValue(values, 'showGrid', false),
    );
  }
}

RenderScene layoutWardley(
  WardleyMap map, {
  required TextMeasurer measurer,
  required MermaidTheme theme,
  WardleyConfig config = const WardleyConfig(),
}) {
  final padding = config.padding;
  final nodeRadius = config.nodeRadius;
  final nodeLabelOffset = config.nodeLabelOffset;
  final axisFontSize = config.axisFontSize;
  final labelFontSize = config.labelFontSize;
  final squareSize = nodeRadius * 1.6;

  final width = map.size?.width ?? config.width;
  final height = map.size?.height ?? config.height;
  final chartWidth = width - padding * 2;
  final chartHeight = height - padding * 2;

  final axisStyle = TextStyleSpec(
    fontFamily: theme.fontFamily,
    fontSize: axisFontSize,
    fontWeight: 700,
  );
  final stageStyle = TextStyleSpec(
    fontFamily: theme.fontFamily,
    fontSize: axisFontSize - 2,
  );
  final labelStyle = TextStyleSpec(
    fontFamily: theme.fontFamily,
    fontSize: labelFontSize,
  );

  final nodes = <SceneNode>[];

  double projectX(double v) => padding + (v / 100) * chartWidth;
  double projectY(double v) => height - padding - (v / 100) * chartHeight;
  Point at(double ex, double vy) => Point(projectX(ex), projectY(vy));

  // Resolve component centers by id and by label.
  final centers = <String, Point>{};
  for (final comp in map.components) {
    centers[comp.name] = at(comp.x, comp.y);
  }
  // Add synthetic pipeline ids.
  for (final p in map.pipelines) {
    final parent = map.components.firstWhere(
      (c) => c.name == p.parent,
      orElse: () => WardleyComponent(p.parent, 0, 50, false),
    );
    for (final memberName in p.componentIds) {
      final id = '${p.parent}_$memberName';
      final mc = map.components.firstWhere(
        (c) => c.name == memberName,
        orElse: () => WardleyComponent(memberName, 0, parent.y, false),
      );
      centers[id] = at(mc.x, parent.y);
    }
  }

  // ---- Title ----
  if (map.title != null && map.title!.isNotEmpty) {
    final style = axisStyle.copyWith(fontSize: axisFontSize * 1.05);
    final ts = measurer.measure(map.title!, style);
    nodes.add(
      SceneText(
        text: map.title!,
        bounds: Rect.fromLTWH(
          width / 2 - ts.width / 2,
          padding / 2 - ts.height / 2,
          ts.width,
          ts.height,
        ),
        style: style,
        color: theme.wardleyAxisTextColor,
      ),
    );
  }

  // ---- Axes (bottom + left L) ----
  nodes.add(
    SceneShape(
      geometry: PathGeometry([
        MoveTo(Point(padding, height - padding)),
        LineTo(Point(width - padding, height - padding)),
      ]),
      stroke: Stroke(color: theme.wardleyAxisColor, width: 1),
    ),
  );

  if (config.showGrid) {
    for (var i = 1; i < 4; i++) {
      final y = padding + chartHeight * i / 4;
      nodes.add(
        SceneShape(
          geometry: PathGeometry([
            MoveTo(Point(padding, y)),
            LineTo(Point(width - padding, y)),
          ]),
          stroke: Stroke(
            color: theme.wardleyAxisColor.withOpacity(0.2),
            width: 1,
            dash: const [3, 3],
          ),
        ),
      );
    }
  }
  nodes.add(
    SceneShape(
      geometry: PathGeometry([
        MoveTo(Point(padding, padding)),
        LineTo(Point(padding, height - padding)),
      ]),
      stroke: Stroke(color: theme.wardleyAxisColor, width: 1),
    ),
  );

  // ---- Axis labels ----
  final xLabel = map.xLabel ?? 'Evolution';
  final yLabel = map.yLabel ?? 'Visibility';
  final xs = measurer.measure(xLabel, axisStyle);
  nodes.add(
    SceneText(
      text: xLabel,
      bounds: Rect.fromLTWH(
        padding + chartWidth / 2 - xs.width / 2,
        height - padding / 4 - xs.height / 2,
        xs.width,
        xs.height,
      ),
      style: axisStyle,
      color: theme.wardleyAxisTextColor,
    ),
  );
  final ys = measurer.measure(yLabel, axisStyle);
  nodes.add(
    SceneText(
      text: yLabel,
      bounds: Rect.fromLTWH(
        padding / 3 - ys.width / 2,
        padding + chartHeight / 2 - ys.height / 2,
        ys.width,
        ys.height,
      ),
      style: axisStyle,
      color: theme.wardleyAxisTextColor,
      rotation: -90,
    ),
  );

  // ---- Evolution stages + dividers ----
  final stages = (map.stages != null && map.stages!.isNotEmpty)
      ? map.stages!
      : _defaultStages;
  final boundaries = map.stageBoundaries;
  final positions = <({double start, double end})>[];
  if (boundaries != null && boundaries.length == stages.length) {
    var prev = 0.0;
    for (final b in boundaries) {
      positions.add((start: prev, end: b));
      prev = b;
    }
  } else {
    final stageWidth = 1.0 / stages.length;
    for (var i = 0; i < stages.length; i++) {
      positions.add((start: i * stageWidth, end: (i + 1) * stageWidth));
    }
  }
  for (var i = 0; i < stages.length; i++) {
    final pos = positions[i];
    final startX = padding + pos.start * chartWidth;
    final endX = padding + pos.end * chartWidth;
    final centerX = (startX + endX) / 2;
    if (i > 0) {
      nodes.add(
        SceneShape(
          geometry: PathGeometry([
            MoveTo(Point(startX, padding)),
            LineTo(Point(startX, height - padding)),
          ]),
          // Upstream draws dividers at opacity 0.8 (wardleyRenderer.ts).
          stroke: Stroke(
            color: theme.wardleyAxisColor.withOpacity(0.8),
            width: 1,
            dash: const [5, 5],
          ),
        ),
      );
    }
    final ss = measurer.measure(stages[i], stageStyle);
    nodes.add(
      SceneText(
        text: stages[i],
        bounds: Rect.fromLTWH(
          centerX - ss.width / 2,
          height - padding / 1.5 - ss.height / 2,
          ss.width,
          ss.height,
        ),
        style: stageStyle,
        color: theme.wardleyAxisTextColor,
      ),
    );
  }

  // ---- Pipeline boxes + evolution links + reposition parent ----
  final pipelineParentNames = <String>{for (final p in map.pipelines) p.parent};
  final pipelineMemberSets = <String, Set<String>>{};
  // Adjusted parent centers (positioned at top of pipeline box).
  final adjustedParent = <String, Point>{};
  for (final p in map.pipelines) {
    final memberIds = [for (final n in p.componentIds) '${p.parent}_$n'];
    pipelineMemberSets[p.parent] = {...memberIds, ...p.componentIds};
    final pts = [
      for (final id in memberIds)
        if (centers[id] != null) centers[id]!,
    ];
    if (pts.isEmpty) continue;
    // Dotted evolution links between consecutive (by x) members.
    final sorted = [...pts]..sort((a, b) => a.x.compareTo(b.x));
    for (var i = 0; i < sorted.length - 1; i++) {
      nodes.add(
        SceneShape(
          geometry: PathGeometry([MoveTo(sorted[i]), LineTo(sorted[i + 1])]),
          stroke: Stroke(
            color: theme.wardleyLinkStroke,
            width: 1,
            dash: const [4, 4],
          ),
        ),
      );
    }
    var minX = double.infinity, maxX = -double.infinity, y = 0.0;
    for (final pt in pts) {
      minX = math.min(minX, pt.x);
      maxX = math.max(maxX, pt.x);
      y = pt.y;
    }
    const boxPad = 15.0;
    final boxHeight = nodeRadius * 4;
    final boxTop = y - boxHeight / 2;
    final centerX = (minX + maxX) / 2;
    adjustedParent[p.parent] = Point(centerX, boxTop - squareSize / 6);
    nodes.add(
      SceneShape(
        geometry: RectGeometry(
          Rect.fromLTWH(
            minX - boxPad,
            boxTop,
            maxX - minX + boxPad * 2,
            boxHeight,
          ),
          rx: 4,
          ry: 4,
        ),
        stroke: Stroke(color: theme.wardleyAxisColor, width: 1.5),
      ),
    );
  }
  // Apply adjusted parent positions to center lookup.
  adjustedParent.forEach((name, pt) => centers[name] = pt);

  // ---- Links ----
  for (final link in map.edges) {
    final fromName = centers.containsKey(link.from)
        ? link.from
        : _resolveId(centers, link.from);
    final toName =
        centers.containsKey(link.to) ? link.to : _resolveId(centers, link.to);
    final a = centers[fromName];
    final b = centers[toName];
    if (a == null || b == null) continue;
    // Filter out pipeline-member → parent links.
    final members = pipelineMemberSets[toName];
    if (members != null &&
        (members.contains(fromName) || members.contains(link.from))) {
      continue;
    }

    final fromIsParent = pipelineParentNames.contains(fromName);
    final toIsParent = pipelineParentNames.contains(toName);
    final rFrom = fromIsParent ? squareSize / math.sqrt2 : nodeRadius;
    final rTo = toIsParent ? squareSize / math.sqrt2 : nodeRadius;

    final dx = b.x - a.x, dy = b.y - a.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) continue;
    final start = Point(a.x + dx / dist * rFrom, a.y + dy / dist * rFrom);
    final end = Point(b.x - dx / dist * rTo, b.y - dy / dist * rTo);

    nodes.add(
      SceneShape(
        geometry: PathGeometry([MoveTo(start), LineTo(end)]),
        stroke: Stroke(
          color: theme.wardleyLinkStroke,
          width: 1,
          dash: link.dashed ? const [6, 6] : null,
        ),
      ),
    );

    // Flow arrowheads.
    if (link.flow == WardleyFlow.forward ||
        link.flow == WardleyFlow.bidirectional) {
      nodes.add(_arrowHead(end, dx, dy, theme.wardleyLinkStroke, 6));
    }
    if (link.flow == WardleyFlow.backward ||
        link.flow == WardleyFlow.bidirectional) {
      nodes.add(_arrowHead(start, -dx, -dy, theme.wardleyLinkStroke, 6));
    }

    // Link label (rotated, offset perpendicular above the line).
    if (link.label != null && link.label!.isNotEmpty) {
      final midX = (a.x + b.x) / 2, midY = (a.y + b.y) / 2;
      const offset = 8.0;
      final perpX = dy / dist, perpY = -dx / dist;
      final lx = midX + perpX * offset, ly = midY + perpY * offset;
      var angle = math.atan2(dy, dx) * 180 / math.pi;
      if (angle > 90 || angle < -90) angle += 180;
      final lls = measurer.measure(link.label!, labelStyle);
      nodes.add(
        SceneText(
          text: link.label!,
          bounds: Rect.fromLTWH(
            lx - lls.width / 2,
            ly - lls.height / 2,
            lls.width,
            lls.height,
          ),
          style: labelStyle,
          color: theme.wardleyAxisTextColor,
          rotation: angle,
        ),
      );
    }
  }

  // ---- Trends (evolve) ----
  for (final comp in map.components) {
    if (comp.evolveTo == null) continue;
    final origin = centers[comp.name];
    if (origin == null) continue;
    final target = at(comp.evolveTo!, comp.y);
    final dx = target.x - origin.x, dy = target.y - origin.y;
    final dist = math.sqrt(dx * dx + dy * dy);
    final shortenBy = nodeRadius + 2;
    final end = dist > shortenBy
        ? Point(
            target.x - dx / dist * shortenBy,
            target.y - dy / dist * shortenBy,
          )
        : target;
    nodes.add(
      SceneShape(
        geometry: PathGeometry([MoveTo(origin), LineTo(end)]),
        stroke: Stroke(
          color: theme.wardleyEvolutionStroke,
          width: 1,
          dash: const [4, 4],
        ),
      ),
    );
    if (dist > 0) {
      nodes.add(_arrowHead(end, dx, dy, theme.wardleyEvolutionStroke, 6));
    }
  }

  // ---- Nodes (overlays, circles, squares, inertia, labels) ----
  for (final comp in map.components) {
    final c = centers[comp.name];
    if (c == null) continue;
    final isParent = comp.isPipelineParent;
    final strat = comp.sourceStrategy;

    // Source-strategy overlay circle behind the main circle.
    if (strat == WardleySourceStrategy.outsource) {
      nodes.add(
        SceneShape(
          geometry: CircleGeometry(c, nodeRadius * 2),
          fill: Fill(theme.wardleyOutsourceFill),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    } else if (strat == WardleySourceStrategy.buy) {
      nodes.add(
        SceneShape(
          geometry: CircleGeometry(c, nodeRadius * 2),
          fill: Fill(theme.wardleyBuyFill),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    } else if (strat == WardleySourceStrategy.build) {
      nodes.add(
        SceneShape(
          geometry: CircleGeometry(c, nodeRadius * 2),
          fill: Fill(theme.wardleyBuildFill),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    } else if (strat == WardleySourceStrategy.market) {
      nodes.add(
        SceneShape(
          geometry: CircleGeometry(c, nodeRadius * 2),
          fill: Fill(theme.canvasColor),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    }

    // Main glyph: square for pipeline parent, market triangle, or circle.
    if (isParent) {
      nodes.add(
        SceneShape(
          geometry: RectGeometry(Rect.fromCenter(c, squareSize, squareSize)),
          fill: Fill(theme.wardleyComponentFill),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    } else if (strat == WardleySourceStrategy.market) {
      _addMarketGlyph(nodes, c, nodeRadius, theme);
    } else if (comp.className != 'anchor') {
      nodes.add(
        SceneShape(
          geometry: CircleGeometry(c, nodeRadius),
          fill: Fill(theme.wardleyComponentFill),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
        ),
      );
    }

    // Inertia bar.
    if (comp.inertia) {
      var offset = isParent ? squareSize / 2 + 15 : nodeRadius + 15;
      if (strat != null) offset += nodeRadius + 10;
      final lineHeight = isParent ? squareSize : nodeRadius * 2;
      final bx = c.x + offset;
      nodes.add(
        SceneShape(
          geometry: PathGeometry([
            MoveTo(Point(bx, c.y - lineHeight / 2)),
            LineTo(Point(bx, c.y + lineHeight / 2)),
          ]),
          stroke: Stroke(color: theme.wardleyComponentStroke, width: 6),
        ),
      );
    }

    // Label.
    final isAnchor = comp.className == 'anchor';
    final ls = measurer.measure(comp.name, labelStyle);
    if (isAnchor) {
      final lx = comp.labelOffsetX != null ? c.x + comp.labelOffsetX! : c.x;
      final ly = comp.labelOffsetY != null ? c.y + comp.labelOffsetY! : c.y - 3;
      nodes.add(
        SceneText(
          text: comp.name,
          bounds: Rect.fromLTWH(
            lx - ls.width / 2,
            ly - ls.height / 2,
            ls.width,
            ls.height,
          ),
          style: labelStyle.copyWith(fontWeight: 700),
          // An anchor has no shape of its own — the bold label *is* the
          // node's mark — so it borrows the component ink
          // (`wardleyComponentStroke`, #000) rather than the component
          // label colour (#222), which upstream never applies to anchors.
          color: theme.wardleyComponentStroke,
        ),
      );
    } else {
      var defOffX = nodeLabelOffset;
      var defOffY = -nodeLabelOffset;
      if (strat != null && comp.labelOffsetX == null) defOffX += 10;
      if (strat != null && comp.labelOffsetY == null) defOffY -= 10;
      final lx = c.x + (comp.labelOffsetX ?? defOffX);
      final ly = c.y + (comp.labelOffsetY ?? defOffY);
      nodes.add(
        SceneText(
          text: comp.name,
          bounds: Rect.fromLTWH(lx, ly - ls.height / 2, ls.width, ls.height),
          style: labelStyle,
          color: theme.wardleyComponentLabelColor,
          align: TextAlignH.left,
        ),
      );
    }
  }

  // ---- Annotations ----
  for (final ann in map.annotations) {
    final p = at(ann.x, ann.y);
    nodes.add(
      SceneShape(
        geometry: CircleGeometry(p, 10),
        fill: Fill(theme.canvasColor),
        stroke: Stroke(color: theme.wardleyAnnotationStroke, width: 1.5),
      ),
    );
    final ns = measurer.measure(
      '${ann.number}',
      labelStyle.copyWith(fontWeight: 700),
    );
    nodes.add(
      SceneText(
        text: '${ann.number}',
        bounds: Rect.fromLTWH(
          p.x - ns.width / 2,
          p.y - ns.height / 2,
          ns.width,
          ns.height,
        ),
        style: labelStyle.copyWith(fontWeight: 700),
        color: theme.wardleyAxisTextColor,
      ),
    );
  }
  // Annotations text box.
  if (map.annotationsBox != null) {
    final boxAnchor = map.annotationsBox!;
    final sorted = [
      for (final a in map.annotations)
        if (a.text != null && a.text!.isNotEmpty) a,
    ]..sort((a, b) => a.number.compareTo(b.number));
    if (sorted.isNotEmpty) {
      const pad = 10.0, lineHeight = 16.0, fontSize = 11.0;
      final boxStyle = TextStyleSpec(
        fontFamily: theme.fontFamily,
        fontSize: fontSize,
      );
      var maxW = 0.0, maxH = 0.0;
      final texts = <(String, double)>[];
      for (var idx = 0; idx < sorted.length; idx++) {
        final t = '${sorted[idx].number}. ${sorted[idx].text}';
        final ms = measurer.measure(t, boxStyle);
        maxW = math.max(maxW, ms.width);
        maxH = math.max(maxH, ms.height);
        texts.add((t, ms.height));
      }
      final boxWidth = maxW + pad * 2 + 105;
      final boxHeight = sorted.length * lineHeight + pad * 2 + maxH / 2;
      var boxX = projectX(boxAnchor.x);
      var boxY = projectY(boxAnchor.y);
      boxX = math.max(padding, math.min(boxX, width - padding - boxWidth));
      boxY = math.max(padding, math.min(boxY, height - padding - boxHeight));
      nodes.add(
        SceneShape(
          geometry: RectGeometry(
            Rect.fromLTWH(boxX, boxY, boxWidth, boxHeight),
            rx: 4,
            ry: 4,
          ),
          fill: Fill(theme.canvasColor),
          stroke: Stroke(color: theme.wardleyAnnotationStroke, width: 1.5),
        ),
      );
      for (var idx = 0; idx < texts.length; idx++) {
        final ty = boxY + pad + (idx + 1) * lineHeight;
        nodes.add(
          SceneText(
            text: texts[idx].$1,
            bounds: Rect.fromLTWH(
              boxX + pad,
              ty - texts[idx].$2 / 2,
              boxWidth - pad * 2,
              texts[idx].$2,
            ),
            style: boxStyle,
            color: theme.wardleyAxisTextColor,
            align: TextAlignH.left,
          ),
        );
      }
    }
  }

  // ---- Notes ----
  for (final note in map.notes) {
    final p = at(note.x, note.y);
    final style = TextStyleSpec(
      fontFamily: theme.fontFamily,
      fontSize: 11,
      fontWeight: 700,
    );
    final ms = measurer.measure(note.text, style);
    nodes.add(
      SceneText(
        text: note.text,
        bounds: Rect.fromLTWH(p.x, p.y - ms.height / 2, ms.width, ms.height),
        style: style,
        color: theme.wardleyAxisTextColor,
        align: TextAlignH.left,
      ),
    );
  }

  // ---- Accelerators / deaccelerators ----
  for (final acc in map.accelerators) {
    _addAccelerator(nodes, measurer, theme, at(acc.x, acc.y), acc.name, false);
  }
  for (final dec in map.deaccelerators) {
    _addAccelerator(nodes, measurer, theme, at(dec.x, dec.y), dec.name, true);
  }

  return RenderScene(
    size: Size(width, height),
    // Upstream: themeVariables.wardley?.backgroundColor ?? background ?? '#fff'.
    // Default theme background is #fff (pixel-identical); dark/forest/neutral
    // follow the theme background.
    background: theme.background,
    nodes: nodes,
  );
}

String _resolveId(Map<String, Point> centers, String name) {
  for (final k in centers.keys) {
    if (k.endsWith('_$name')) return k;
  }
  return name;
}

/// A small filled triangular arrowhead at [tip] pointing along (dx, dy).
SceneShape _arrowHead(
  Point tip,
  double dx,
  double dy,
  Color color,
  double size,
) {
  final len = math.sqrt(dx * dx + dy * dy);
  final ux = len == 0 ? 1.0 : dx / len;
  final uy = len == 0 ? 0.0 : dy / len;
  // Perpendicular.
  final px = -uy, py = ux;
  final back = Point(tip.x - ux * size, tip.y - uy * size);
  final half = size * 0.5;
  final p1 = Point(back.x + px * half, back.y + py * half);
  final p2 = Point(back.x - px * half, back.y - py * half);
  return SceneShape(
    geometry: PolygonGeometry([tip, p1, p2]),
    fill: Fill(color),
  );
}

/// Three small white circles in a triangle with connecting lines (market).
void _addMarketGlyph(
  List<SceneNode> nodes,
  Point c,
  double nodeRadius,
  MermaidTheme theme,
) {
  final small = nodeRadius * 0.7;
  final tri = nodeRadius * 1.2;
  final cos = math.cos(math.pi / 6), sin = math.sin(math.pi / 6);
  final top = Point(c.x, c.y - tri);
  final bl = Point(c.x - tri * cos, c.y + tri * sin);
  final br = Point(c.x + tri * cos, c.y + tri * sin);
  for (final (a, b) in [(top, bl), (bl, br), (br, top)]) {
    nodes.add(
      SceneShape(
        geometry: PathGeometry([MoveTo(a), LineTo(b)]),
        stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
      ),
    );
  }
  for (final pt in [top, bl, br]) {
    nodes.add(
      SceneShape(
        geometry: CircleGeometry(pt, small),
        fill: Fill(theme.canvasColor),
        stroke: Stroke(color: theme.wardleyComponentStroke, width: 2),
      ),
    );
  }
}

/// A 60×30 chevron arrow (right-pointing unless [left]) with a bold label below.
void _addAccelerator(
  List<SceneNode> nodes,
  TextMeasurer measurer,
  MermaidTheme theme,
  Point p,
  String name,
  bool left,
) {
  const w = 60.0, h = 30.0, headW = 20.0;
  final List<Point> pts;
  if (!left) {
    pts = [
      Point(p.x, p.y - h / 2),
      Point(p.x + w - headW, p.y - h / 2),
      Point(p.x + w - headW, p.y - h / 2 - 8),
      Point(p.x + w, p.y),
      Point(p.x + w - headW, p.y + h / 2 + 8),
      Point(p.x + w - headW, p.y + h / 2),
      Point(p.x, p.y + h / 2),
    ];
  } else {
    pts = [
      Point(p.x + w, p.y - h / 2),
      Point(p.x + headW, p.y - h / 2),
      Point(p.x + headW, p.y - h / 2 - 8),
      Point(p.x, p.y),
      Point(p.x + headW, p.y + h / 2 + 8),
      Point(p.x + headW, p.y + h / 2),
      Point(p.x + w, p.y + h / 2),
    ];
  }
  nodes.add(
    SceneShape(
      geometry: PolygonGeometry(pts),
      fill: Fill(theme.canvasColor),
      stroke: Stroke(color: theme.wardleyComponentStroke, width: 1),
    ),
  );
  final style = TextStyleSpec(
    fontFamily: theme.fontFamily,
    fontSize: 10,
    fontWeight: 700,
  );
  final ms = measurer.measure(name, style);
  nodes.add(
    SceneText(
      text: name,
      bounds: Rect.fromLTWH(
        p.x + w / 2 - ms.width / 2,
        p.y + h / 2 + 15 - ms.height / 2,
        ms.width,
        ms.height,
      ),
      style: style,
      color: theme.wardleyAxisTextColor,
    ),
  );
}
