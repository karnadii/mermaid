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
class _IndexedBk {
  _IndexedBk(this.g, List<List<String>> layering) {
    for (final layer in layering) {
      final ids = <int>[];
      for (final v in layer) {
        index[v] = names.length;
        ids.add(names.length);
        names.add(v);
      }
      layers.add(ids);
    }
    final n = names.length;
    for (var i = 0; i < n; i++) {
      final label = g.node(names[i]);
      order.add(label.getD(orderK));
      width.add(label.getD(widthK));
      final dummy = label[dummyK];
      isDummy.add(dummy != null);
      isBorder.add(Dummy.border == dummy);
      labelPos.add(label[labelPosK]);
      borderType.add(label[borderTypeK]);
    }
    for (var i = 0; i < n; i++) {
      preds.add([
        for (final u in g.predecessors(names[i]) ?? const <String>[]) index[u]!,
      ]);
      succs.add([
        for (final w in g.successors(names[i]) ?? const <String>[]) index[w]!,
      ]);
    }
  }

  final Graph g;
  final Map<String, int> index = {};
  final List<String> names = [];
  final List<List<int>> layers = [];
  final List<double> order = [];
  final List<double> width = [];
  final List<bool> isDummy = [];
  final List<bool> isBorder = [];
  final List<Object?> labelPos = [];
  final List<Object?> borderType = [];
  final List<List<int>> preds = [];
  final List<List<int>> succs = [];

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
    final label = g.label;
    // Block graph over roots, in insertion order, with one edge per pair.
    final blockNodes = <int>[];
    final inBlock = List<bool>.filled(n, false);
    final blockPreds = List<List<int>>.generate(n, (_) => []);
    final blockSuccs = List<List<int>>.generate(n, (_) => []);
    final sepValue = <int, double>{};
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
          final key = uRoot * n + vRoot;
          final prev = sepValue[key];
          final s = _sep(v, u, reverseSep, label.nodeSep, label.edgeSep);
          sepValue[key] = math.max(s, prev ?? 0).toDouble();
          if (prev == null) {
            blockSuccs[uRoot].add(vRoot);
            blockPreds[vRoot].add(uRoot);
          }
        }
        u = v;
      }
    }

    final xs = List<double?>.filled(n, null);
    void iterate(void Function(int) setXs, List<List<int>> next) {
      final stack = List<int>.of(blockNodes);
      final visited = List<bool>.filled(n, false);
      while (stack.isNotEmpty) {
        final elem = stack.removeLast();
        if (visited[elem]) {
          setXs(elem);
        } else {
          visited[elem] = true;
          stack.add(elem);
          stack.addAll(next[elem]);
        }
      }
    }

    iterate((elem) {
      num acc = 0;
      for (final u in blockPreds[elem]) {
        acc = math.max(acc, xs[u]! + sepValue[u * n + elem]!);
      }
      xs[elem] = acc.toDouble();
    }, blockPreds);

    final ownBorder = reverseSep ? 'borderLeft' : 'borderRight';
    iterate((elem) {
      num minv = double.maxFinite;
      for (final w in blockSuccs[elem]) {
        minv = math.min(minv, xs[w]! - sepValue[elem * n + w]!);
      }
      if (minv != double.maxFinite && borderType[elem] != ownBorder) {
        xs[elem] = math.max(xs[elem] as num, minv).toDouble();
      }
    }, blockSuccs);

    return [for (var v = 0; v < n; v++) xs[root[v]]!];
  }

  Map<String, double> run() {
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
    final fixed = g.label.align;
    final result = <String, double>{};
    final four = List<double>.filled(4, 0);
    for (var v = 0; v < n; v++) {
      if (fixed != null) {
        result[names[v]] = alignments[fixed]![v];
      } else {
        four[0] = alignments[GraphAlign.utl]![v];
        four[1] = alignments[GraphAlign.utr]![v];
        four[2] = alignments[GraphAlign.dtl]![v];
        four[3] = alignments[GraphAlign.dtr]![v];
        four.sort();
        result[names[v]] = (four[1] + four[2]) / 2;
      }
    }
    return result;
  }
}
