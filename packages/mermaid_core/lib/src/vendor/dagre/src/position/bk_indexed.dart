part of 'bk.dart';

/// Brandes-Köpf x-coordinates over integer indices instead of string-keyed
/// maps. It reproduces the reference code above step for step, including the
/// behaviour of this port that differs from dagre.js, because the output
/// must not change:
/// - _findType2Conflicts reduces with swapped arguments, so every layer is
///   checked as `north` against layer 0 as `south`, and the trailing scan
///   runs once per south node instead of once per layer,
/// - _findSmallestWidthAlignment starts its maximum at double.minPositive.
/// Neighbour lists keep the graph's insertion order, so `find`, `sort` and
/// the compaction stack see the same sequences as the reference code.
class IndexedBk {
  IndexedBk(
    this.label,
    this.names,
    this.layers,
    this.order,
    this.width,
    this.isDummy,
    this.isBorder,
    this.labelPos,
    this.borderType,
    this.preds,
    this.succs,
  );

  /// From the non-compound copy that the reference position() makes.
  factory IndexedBk.fromGraph(Graph g, List<List<String>> layering) {
    final index = <String, int>{};
    final names = <String>[];
    final layers = <List<int>>[];
    for (final layer in layering) {
      final ids = <int>[];
      for (final v in layer) {
        index[v] = names.length;
        ids.add(names.length);
        names.add(v);
      }
      layers.add(ids);
    }
    final labels = [for (final v in names) g.node(v)];
    return IndexedBk(
      g.label,
      names,
      layers,
      [for (final l in labels) l.getD(orderK)],
      [for (final l in labels) l.getD(widthK)],
      [for (final l in labels) l[dummyK] != null],
      [for (final l in labels) Dummy.border == l[dummyK]],
      [for (final l in labels) l[labelPosK]],
      [for (final l in labels) l[borderTypeK]],
      [
        for (final v in names)
          [for (final u in g.predecessors(v) ?? const <String>[]) index[u]!],
      ],
      [
        for (final v in names)
          [for (final w in g.successors(v) ?? const <String>[]) index[w]!],
      ],
    );
  }

  final GraphLabel label;
  final List<String> names;
  final List<List<int>> layers;
  final List<double> order;
  final List<double> width;
  final List<bool> isDummy;
  final List<bool> isBorder;
  final List<Object?> labelPos;
  final List<Object?> borderType;
  final List<List<int>> preds;
  final List<List<int>> succs;

  /// Conflicting (u, v) pairs, stored as `min * n + max`.
  final Set<int> conflicts = {};

  int get n => names.length;

  void _addConflict(int u, int v) =>
      conflicts.add(u < v ? u * n + v : v * n + u);

  bool _hasConflict(int u, int v) =>
      conflicts.contains(u < v ? u * n + v : v * n + u);

  void _findType1Conflicts() {
    for (var l = 1; l < layers.length; l++) {
      final prevLayerLength = layers[l - 1].length;
      final layer = layers[l];
      final lastNode = layer.last;
      var k0 = 0.0;
      var scanPos = 0;
      for (var i = 0; i < layer.length; i++) {
        final v = layer[i];
        int? w;
        if (isDummy[v]) {
          for (final u in preds[v]) {
            if (isDummy[u]) {
              w = u;
              break;
            }
          }
        }
        final k1 = w != null ? order[w] : prevLayerLength.toDouble();
        if (w != null || v == lastNode) {
          for (var s = scanPos; s <= i; s++) {
            final scanNode = layer[s];
            for (final u in preds[scanNode]) {
              final uPos = order[u];
              if ((uPos < k0 || k1 < uPos) &&
                  !(isDummy[u] && isDummy[scanNode])) {
                _addConflict(u, scanNode);
              }
            }
          }
          scanPos = i + 1;
          k0 = k1;
        }
      }
    }
  }

  void _findType2Conflicts() {
    if (layers.isEmpty) return;
    final south = layers[0];
    void scan(
      int from,
      int to,
      double prevNorthBorder,
      double nextNorthBorder,
    ) {
      for (var i = from; i < to; i++) {
        final v = south[i];
        if (!isDummy[v]) continue;
        for (final u in preds[v]) {
          if (isDummy[u] &&
              (order[u] < prevNorthBorder || order[u] > nextNorthBorder)) {
            _addConflict(u, v);
          }
        }
      }
    }

    for (var l = 1; l < layers.length; l++) {
      final northLength = layers[l].length.toDouble();
      var prevNorthPos = -1.0;
      double? nextNorthPos;
      var southPos = 0;
      // The trailing scan repeats with the same arguments until a border
      // node moves them; repeating it cannot add conflicts.
      int? lastFrom;
      double? lastBorder;
      for (
        var southLookahead = 0;
        southLookahead < south.length;
        southLookahead++
      ) {
        final v = south[southLookahead];
        if (isBorder[v] && preds[v].isNotEmpty) {
          nextNorthPos = order[preds[v][0]];
          scan(southPos, southLookahead, prevNorthPos, nextNorthPos);
          southPos = southLookahead;
          prevNorthPos = nextNorthPos;
        }
        final border = nextNorthPos ?? double.nan;
        if (lastFrom == southPos &&
            (lastBorder == border || (lastBorder!.isNaN && border.isNaN))) {
          continue;
        }
        lastFrom = southPos;
        lastBorder = border;
        scan(southPos, south.length, border, northLength);
      }
    }
  }

  /// Returns the block root of every node.
  List<int> _verticalAlignment(
    List<List<int>> layering,
    List<List<int>> neighbors,
  ) {
    final root = List<int>.generate(n, (i) => i);
    final align = List<int>.generate(n, (i) => i);
    final pos = List<int>.filled(n, 0);
    for (final layer in layering) {
      for (var i = 0; i < layer.length; i++) {
        pos[layer[i]] = i;
      }
    }
    for (final layer in layering) {
      var prevIdx = -1;
      for (final v in layer) {
        final ws = List<int>.of(neighbors[v]);
        if (ws.isEmpty) continue;
        ws.sort((a, b) => pos[a].compareTo(pos[b]));
        final mp = (ws.length - 1) / 2;
        for (int i = mp.floor(), il = mp.ceil(); i <= il; ++i) {
          final w = ws[i];
          if (align[v] == v && prevIdx < pos[w] && !_hasConflict(v, w)) {
            align[w] = v;
            align[v] = root[v] = root[w];
            prevIdx = pos[w];
          }
        }
      }
    }
    return root;
  }

  double _sep(int v, int w, bool reverseSep, num nodeSep, num edgeSep) {
    num sum = 0;
    num delta = 0;
    sum += width[v] / 2;
    if (labelPos[v] == LabelPosition.left) {
      delta = -width[v] / 2;
    } else if (labelPos[v] == LabelPosition.right) {
      delta = width[v] / 2;
    }
    if (delta != 0) {
      sum += reverseSep ? delta : -delta;
    }
    delta = 0;
    sum += (isDummy[v] ? edgeSep : nodeSep) / 2;
    sum += (isDummy[w] ? edgeSep : nodeSep) / 2;
    sum += width[w] / 2;
    if (labelPos[w] == LabelPosition.left) {
      delta = width[w] / 2;
    } else if (labelPos[w] == LabelPosition.right) {
      delta = -width[w] / 2;
    }
    if (delta != 0) {
      sum += reverseSep ? delta : -delta;
    }
    return sum.toDouble();
  }

  List<double> _horizontalCompaction(
    List<List<int>> layering,
    List<int> root,
    bool reverseSep,
  ) {
    // Block graph over roots: nodes in insertion order, one edge per pair
    // holding the largest separation, adjacency in insertion order.
    final blockNodes = <int>[];
    final inBlock = List<bool>.filled(n, false);
    final blockIn = List<List<int>>.generate(n, (_) => []);
    final blockOut = List<List<int>>.generate(n, (_) => []);
    final edgeFrom = <int>[], edgeTo = <int>[];
    final edgeSep = <double>[];
    final edgeOf = <int, int>{};
    for (final layer in layering) {
      int? u;
      for (final v in layer) {
        final vRoot = root[v];
        if (!inBlock[vRoot]) {
          inBlock[vRoot] = true;
          blockNodes.add(vRoot);
        }
        if (u != null) {
          final uRoot = root[u];
          final s = _sep(v, u, reverseSep, label.nodeSep, label.edgeSep);
          final key = uRoot * n + vRoot;
          final e = edgeOf[key];
          if (e == null) {
            edgeOf[key] = edgeSep.length;
            blockOut[uRoot].add(edgeSep.length);
            blockIn[vRoot].add(edgeSep.length);
            edgeFrom.add(uRoot);
            edgeTo.add(vRoot);
            edgeSep.add(math.max(s, 0).toDouble());
          } else {
            edgeSep[e] = math.max(s, edgeSep[e]).toDouble();
          }
        }
        u = v;
      }
    }

    // Both passes walk the block graph with the reference's explicit stack:
    // a node's coordinate is (re)computed each time it is popped after its
    // first visit.
    final xs = Float64List(n);
    final visited = List<bool>.filled(n, false);
    final stack = <int>[];

    // First pass, assign smallest coordinates.
    stack.addAll(blockNodes);
    while (stack.isNotEmpty) {
      final elem = stack.removeLast();
      if (visited[elem]) {
        num acc = 0;
        for (final e in blockIn[elem]) {
          acc = math.max(acc, xs[edgeFrom[e]] + edgeSep[e]);
        }
        xs[elem] = acc.toDouble();
      } else {
        visited[elem] = true;
        stack.add(elem);
        for (final e in blockIn[elem]) {
          stack.add(edgeFrom[e]);
        }
      }
    }

    // Second pass, assign greatest coordinates.
    final ownBorder = reverseSep ? 'borderLeft' : 'borderRight';
    visited.fillRange(0, n, false);
    stack.addAll(blockNodes);
    while (stack.isNotEmpty) {
      final elem = stack.removeLast();
      if (visited[elem]) {
        num minv = double.maxFinite;
        for (final e in blockOut[elem]) {
          minv = math.min(minv, xs[edgeTo[e]] - edgeSep[e]);
        }
        if (minv != double.maxFinite && borderType[elem] != ownBorder) {
          xs[elem] = math.max(xs[elem], minv).toDouble();
        }
      } else {
        visited[elem] = true;
        stack.add(elem);
        for (final e in blockOut[elem]) {
          stack.add(edgeTo[e]);
        }
      }
    }

    return [for (var v = 0; v < n; v++) xs[root[v]]];
  }

  Map<String, double> run() {
    final xs = runIndexed();
    return {for (var v = 0; v < n; v++) names[v]: xs[v]};
  }

  /// Balanced x per node, in [names] order.
  List<double> runIndexed() {
    _findType1Conflicts();
    _findType2Conflicts();

    final down = layers.reversed.toList();
    List<List<int>> reversedInner(List<List<int>> l) => [
      for (final layer in l) layer.reversed.toList(),
    ];
    final alignments = <GraphAlign, List<double>>{};
    for (final (align, layering, neighbors, right) in [
      (GraphAlign.utl, layers, preds, false),
      (GraphAlign.utr, reversedInner(layers), preds, true),
      (GraphAlign.dtl, down, succs, false),
      (GraphAlign.dtr, reversedInner(down), succs, true),
    ]) {
      final root = _verticalAlignment(layering, neighbors);
      var xs = _horizontalCompaction(layering, root, right);
      if (right) xs = [for (final x in xs) -x];
      alignments[align] = xs;
    }

    // _findSmallestWidthAlignment
    List<double>? alignTo;
    var best = double.infinity;
    for (final xs in alignments.values) {
      double maxX = double.minPositive;
      double minX = double.maxFinite;
      for (var v = 0; v < n; v++) {
        final halfWidth = width[v] / 2;
        maxX = math.max(xs[v] + halfWidth, maxX);
        minX = math.min(xs[v] - halfWidth, minX);
      }
      if (maxX - minX < best) {
        best = maxX - minX;
        alignTo = xs;
      }
    }

    // _alignCoordinates
    if (alignTo != null && n > 0) {
      final alignToMin = alignTo.reduce(math.min);
      final alignToMax = alignTo.reduce(math.max);
      for (final align in GraphAlign.values) {
        final xs = alignments[align]!;
        if (identical(xs, alignTo)) continue;
        final delta = align == GraphAlign.utl || align == GraphAlign.dtl
            ? alignToMin - xs.reduce(math.min)
            : alignToMax - xs.reduce(math.max);
        if (delta != 0) {
          alignments[align] = [for (final x in xs) x + delta];
        }
      }
    }

    // _balance
    final fixed = label.align;
    final result = List<double>.filled(n, 0);
    final four = List<double>.filled(4, 0);
    for (var v = 0; v < n; v++) {
      if (fixed != null) {
        result[v] = alignments[fixed]![v];
      } else {
        four[0] = alignments[GraphAlign.utl]![v];
        four[1] = alignments[GraphAlign.utr]![v];
        four[2] = alignments[GraphAlign.dtl]![v];
        four[3] = alignments[GraphAlign.dtr]![v];
        four.sort();
        result[v] = (four[1] + four[2]) / 2;
      }
    }
    return result;
  }
}

/// [position] without the non-compound copy: the same leaf nodes, layering,
/// y and x coordinates, computed on indices and written to the same labels.
/// Predecessors and successors follow the global edge order, which is the
/// order the copy's adjacency maps get. Returns false when the reference
/// code must run: an edge ends at a cluster node, a neighbour has no rank,
/// or a rank is negative.
bool positionIndexed(Graph g) {
  final index = <String, int>{};
  final labels = <Props>[];
  for (final v in g.nodesIterable) {
    final children = g.children(v);
    if (children == null || children.isEmpty) {
      index[v] = labels.length;
      labels.add(g.node(v));
    }
  }
  final count = labels.length;
  if (count == 0) return false;
  final predsAll = List<List<int>>.generate(count, (_) => []);
  final succsAll = List<List<int>>.generate(count, (_) => []);
  for (final e in g.edgesIterable) {
    final v = index[e.v], w = index[e.w];
    if (v == null || w == null) return false;
    if (!predsAll[w].contains(v)) predsAll[w].add(v);
    if (!succsAll[v].contains(w)) succsAll[v].add(w);
  }

  // buildLayerMatrix: maxRank over all nodes (no rank counts as
  // double.minPositive), then per rank the nodes keyed by order.
  double maxRankValue = labels[0].getD2(rankK) ?? double.minPositive;
  final rankOf = List<int?>.filled(count, null);
  for (var i = 0; i < count; i++) {
    final r = labels[i].getD2(rankK);
    maxRankValue = math.max(maxRankValue, r ?? double.minPositive);
    rankOf[i] = labels[i].getI2(rankK);
  }
  final byOrder = List<Map<int, int>>.generate(
    maxRankValue.toInt() + 1,
    (_) => {},
  );
  for (var i = 0; i < count; i++) {
    final r = rankOf[i];
    if (r == null) continue;
    if (r < 0 || r >= byOrder.length) return false;
    byOrder[r][labels[i].getI(orderK)] = i;
  }

  // Renumber the layered nodes in layer order, as the BK code expects.
  final local = List<int>.filled(count, -1);
  final names = <String>[];
  final layerLabels = <Props>[];
  final layers = <List<int>>[];
  final globalOf = <int>[];
  for (final m in byOrder) {
    final ids = <int>[];
    for (final k in (m.keys.toList()..sort())) {
      final i = m[k]!;
      local[i] = globalOf.length;
      ids.add(globalOf.length);
      globalOf.add(i);
      layerLabels.add(labels[i]);
    }
    layers.add(ids);
  }
  // Names are only used to key the result map of run(); not needed here.
  names.addAll(List.filled(layerLabels.length, ''));
  final preds = <List<int>>[];
  final succs = <List<int>>[];
  for (final i in globalOf) {
    final p = <int>[], s = <int>[];
    for (final u in predsAll[i]) {
      if (local[u] < 0) return false;
      p.add(local[u]);
    }
    for (final w in succsAll[i]) {
      if (local[w] < 0) return false;
      s.add(local[w]);
    }
    preds.add(p);
    succs.add(s);
  }

  // positionY
  final rankSep = g.label.rankSep;
  num prevY = 0;
  for (final layer in layers) {
    num? maxHeight;
    for (final v in layer) {
      final h = layerLabels[v].getD(heightK);
      maxHeight = maxHeight == null ? h : math.max(maxHeight, h);
    }
    maxHeight ??= 0;
    for (final v in layer) {
      layerLabels[v][yK] = prevY + maxHeight / 2;
    }
    prevY += maxHeight + rankSep;
  }

  final bk = IndexedBk(
    g.label,
    names,
    layers,
    [for (final l in layerLabels) l.getD(orderK)],
    [for (final l in layerLabels) l.getD(widthK)],
    [for (final l in layerLabels) l[dummyK] != null],
    [for (final l in layerLabels) Dummy.border == l[dummyK]],
    [for (final l in layerLabels) l[labelPosK]],
    [for (final l in layerLabels) l[borderTypeK]],
    preds,
    succs,
  );
  final xs = bk.runIndexed();
  for (var v = 0; v < xs.length; v++) {
    layerLabels[v][xK] = xs[v];
  }
  return true;
}
