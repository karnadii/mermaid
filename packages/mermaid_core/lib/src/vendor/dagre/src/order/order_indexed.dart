part of 'index.dart';

/// One layer graph of [buildLayerGraph] over node indices.
///
/// Node ids are indices into `g.nodes`; the synthetic root of each layer
/// graph gets an id past the last node. It keeps exactly what the sweeps read:
/// - children of each node, in the order buildLayerGraph parents them,
/// - in-edge sources with summed weights, in insertion order,
/// - the border nodes of clusters at this rank,
/// - which nodes have their own label (clusters), because order writes to
///   those labels do not reach `g`.
class IndexedLayerGraph {
  IndexedLayerGraph(this.root);

  final int root;
  final Map<int, List<int>> children = {};
  final Map<int, int> parent = {};
  final Map<int, List<int>> inSources = {};
  final Map<int, List<double>> inWeights = {};
  final Map<int, (int?, int?)> borders = {};
  final Set<int> ownLabel = {};
}

class _Entry {
  _Entry(this.v);

  final int v;
  num? barycenter;
  num? weight;
}

class _Conflict {
  num inDegree = 0;
  List<_Conflict> inner = [];
  List<_Conflict> out = [];
  List<int> vs = [];
  int i = -1;
  num? barycenter;
  num weight = 0;
  bool merged = false;
}

class _Sorted {
  List<int> vs = [];
  late int i;
  num? barycenter;
  late num weight;
}

/// The barycenter sweeps of [order] over node indices. Each step mirrors the
/// string-keyed code in this directory (sortSubgraph, barycenter,
/// resolveConflicts, sort, addSubgraphConstraints, crossCount,
/// buildLayerMatrix) in the same iteration order, so the result is the same.
class IndexedOrder {
  /// [order] and [rank] are per node index; [outTargets]/[outWeights]
  /// list each node's out-edges in edge order, as crossCount reads them.
  IndexedOrder(
    this.order,
    this.rank,
    this.outTargets,
    this.outWeights,
    this.down,
    this.up,
  );

  /// From the layout graph [g], whose node indices are [names].
  factory IndexedOrder.fromGraph(
    Graph g,
    List<String> names,
    List<IndexedLayerGraph> down,
    List<IndexedLayerGraph> up,
  ) {
    final index = {for (var i = 0; i < names.length; i++) names[i]: i};
    final order = <double>[];
    final rank = <int?>[];
    final outTargets = <List<int>>[];
    final outWeights = <List<num>>[];
    for (var i = 0; i < names.length; i++) {
      final label = g.node(names[i]);
      order.add(label.getD2(orderK) ?? 0);
      rank.add(label.getI2(rankK));
      final outs = <int>[];
      final weights = <num>[];
      for (final e in g.outEdges(names[i]) ?? const <Edge>[]) {
        outs.add(index[e.w]!);
        weights.add(g.edge2(e)[weightK]);
      }
      outTargets.add(outs);
      outWeights.add(weights);
    }
    return IndexedOrder(order, rank, outTargets, outWeights, down, up);
  }

  final List<IndexedLayerGraph> down;
  final List<IndexedLayerGraph> up;
  final List<double> order;
  final List<int?> rank;
  final List<List<int>> outTargets;
  final List<List<num>> outWeights;

  int get nodeCount => order.length;

  /// Runs the sweeps and returns the layering with the fewest crossings.
  List<List<int>> run(int maxRank) {
    num bestCC = double.infinity;
    List<List<int>> best = [];
    for (int i = 0, lastBest = 0; lastBest < 4; ++i, ++lastBest) {
      _sweep((i % 2) != 0 ? down : up, i % 4 >= 2);
      final layering = _layerMatrix(maxRank);
      final cc = _crossCount(layering);
      if (cc < bestCC) {
        lastBest = 0;
        best = [for (final layer in layering) List<int>.of(layer)];
        bestCC = cc;
      }
    }
    return best;
  }

  void _sweep(List<IndexedLayerGraph> layerGraphs, bool biasRight) {
    // Constraint graph: unique edges in insertion order.
    final cgEdges = <(int, int)>[];
    final cgKeys = <(int, int)>{};
    for (final lg in layerGraphs) {
      final sorted = _sortSubgraph(lg, lg.root, cgEdges, biasRight);
      for (var i = 0; i < sorted.vs.length; i++) {
        final v = sorted.vs[i];
        if (!lg.ownLabel.contains(v)) order[v] = i.toDouble();
      }
      // addSubgraphConstraints
      final prev = <int, int>{};
      int? rootPrev;
      for (final v in sorted.vs) {
        int? child = lg.parent[v];
        while (child != null) {
          final parent = lg.parent[child];
          int? prevChild;
          if (parent != null) {
            prevChild = prev[parent];
            prev[parent] = child;
          } else {
            prevChild = rootPrev;
            rootPrev = child;
          }
          if (prevChild != null && prevChild != child) {
            if (cgKeys.add((prevChild, child))) cgEdges.add((prevChild, child));
            break;
          }
          child = parent;
        }
      }
    }
  }

  _Sorted _sortSubgraph(
    IndexedLayerGraph lg,
    int v,
    List<(int, int)> cgEdges,
    bool biasRight,
  ) {
    var movable = lg.children[v] ?? const <int>[];
    final (bl, br) = lg.borders[v] ?? (null, null);
    if (bl != null) {
      movable = [
        for (final w in movable)
          if (w != bl && w != br) w,
      ];
    }

    final barycenters = <_Entry>[];
    for (final w in movable) {
      final entry = _Entry(w);
      final sources = lg.inSources[w];
      if (sources != null && sources.isNotEmpty) {
        final weights = lg.inWeights[w]!;
        num sum = 0, weight = 0;
        for (var i = 0; i < sources.length; i++) {
          sum = sum + weights[i] * order[sources[i]];
          weight = weight + weights[i];
        }
        entry.barycenter = sum / weight;
        entry.weight = weight;
      }
      barycenters.add(entry);
    }

    final subgraphs = <int, _Sorted>{};
    for (final entry in barycenters) {
      final list = lg.children[entry.v];
      if (list != null && list.isNotEmpty) {
        final sub = _sortSubgraph(lg, entry.v, cgEdges, biasRight);
        subgraphs[entry.v] = sub;
        if (sub.barycenter != null) {
          if (entry.barycenter != null) {
            entry.barycenter =
                (entry.barycenter! * entry.weight! +
                    sub.barycenter! * sub.weight) /
                (entry.weight! + sub.weight);
            entry.weight = entry.weight! + sub.weight;
          } else {
            entry.barycenter = sub.barycenter;
            entry.weight = sub.weight;
          }
        }
      }
    }

    final entries = _resolveConflicts(barycenters, cgEdges);
    for (final entry in entries) {
      final expanded = <int>[];
      for (final w in entry.vs) {
        final sub = subgraphs[w];
        if (sub != null) {
          expanded.addAll(sub.vs);
        } else {
          expanded.add(w);
        }
      }
      entry.vs = expanded;
    }
    final result = _sort(entries, biasRight);
    if (bl != null) {
      result.vs = [bl, ...result.vs, br!];
      final blPreds = lg.inSources[bl] ?? const <int>[];
      if (blPreds.isNotEmpty) {
        final blPred = order[blPreds[0]];
        final brPred = order[lg.inSources[br]![0]];
        if (result.barycenter == null) {
          result.barycenter = 0;
          result.weight = 0;
        }
        result.barycenter =
            (result.barycenter! * result.weight + blPred + brPred) /
            (result.weight + 2);
        result.weight = result.weight + 2;
      }
    }
    return result;
  }

  List<_Sorted> _resolveConflicts(
    List<_Entry> entries,
    List<(int, int)> cgEdges,
  ) {
    final mapped = <int, _Conflict>{};
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final tmp = _Conflict()
        ..vs = [entry.v]
        ..i = i;
      mapped[entry.v] = tmp;
      if (entry.barycenter != null) {
        tmp.barycenter = entry.barycenter!;
        tmp.weight = entry.weight!;
      }
    }
    for (final (v, w) in cgEdges) {
      final entryV = mapped[v];
      final entryW = mapped[w];
      if (entryV != null && entryW != null) {
        entryW.inDegree += 1;
        entryV.out.add(entryW);
      }
    }
    final sourceSet = [
      for (final e in mapped.values)
        if (e.inDegree == 0) e,
    ];

    final resolved = <_Conflict>[];
    while (sourceSet.isNotEmpty) {
      final entry = sourceSet.removeLast();
      resolved.add(entry);
      for (final uEntry in entry.inner.reversed) {
        if (uEntry.merged) continue;
        if (uEntry.barycenter == null ||
            entry.barycenter == null ||
            uEntry.barycenter! >= entry.barycenter!) {
          _mergeEntries(entry, uEntry);
        }
      }
      for (final wEntry in entry.out) {
        wEntry.inner.add(entry);
        if (--wEntry.inDegree == 0) sourceSet.add(wEntry);
      }
    }
    return [
      for (final entry in resolved)
        if (!entry.merged)
          _Sorted()
            ..vs = entry.vs
            ..i = entry.i
            ..barycenter = entry.barycenter
            ..weight = entry.weight,
    ];
  }

  void _mergeEntries(_Conflict target, _Conflict source) {
    num sum = 0;
    num weight = 0;
    if (target.weight != 0) {
      sum += target.barycenter! * target.weight;
      weight += target.weight;
    }
    if (source.weight != 0) {
      sum += source.barycenter! * source.weight;
      weight += source.weight;
    }
    target.vs = [...source.vs, ...target.vs];
    target.barycenter = sum / weight;
    target.weight = weight;
    target.i = math.min(source.i, target.i);
    source.merged = true;
  }

  _Sorted _sort(List<_Sorted> entries, bool biasRight) {
    final sortable = <_Sorted>[];
    final unsortable = <_Sorted>[];
    for (final entry in entries) {
      (entry.barycenter != null ? sortable : unsortable).add(entry);
    }
    unsortable.sort((a, b) => b.i.compareTo(a.i));
    final vs = <int>[];
    num sum = 0, weight = 0;
    var vsIndex = 0;
    sortable.sort((entryV, entryW) {
      if (entryV.barycenter! < entryW.barycenter!) return -1;
      if (entryV.barycenter! > entryW.barycenter!) return 1;
      return !biasRight ? entryV.i - entryW.i : entryW.i - entryV.i;
    });
    int consume(int index) {
      while (unsortable.isNotEmpty && unsortable.last.i <= index) {
        vs.addAll(unsortable.removeLast().vs);
        index++;
      }
      return index;
    }

    vsIndex = consume(vsIndex);
    for (final entry in sortable) {
      vsIndex += entry.vs.length;
      vs.addAll(entry.vs);
      sum += entry.barycenter! * entry.weight;
      weight += entry.weight;
      vsIndex = consume(vsIndex);
    }
    final result = _Sorted()..vs = vs;
    if (weight != 0) {
      result.barycenter = sum / weight;
      result.weight = weight;
    }
    return result;
  }

  /// buildLayerMatrix: per rank, nodes keyed by order (a later node with
  /// the same order replaces an earlier one), sorted by order.
  List<List<int>> _layerMatrix(int maxRank) {
    final byOrder = List<Map<int, int>>.generate(maxRank + 1, (_) => {});
    for (var v = 0; v < nodeCount; v++) {
      final r = rank[v];
      if (r != null) byOrder[r][order[v].toInt()] = v;
    }
    return [
      for (final m in byOrder)
        [for (final k in (m.keys.toList()..sort())) m[k]!],
    ];
  }

  int _crossCount(List<List<int>> layering) {
    var cc = 0;
    final southPos = List<int>.filled(nodeCount, 0);
    for (var l = 1; l < layering.length; ++l) {
      final north = layering[l - 1], south = layering[l];
      for (var i = 0; i < south.length; i++) {
        southPos[south[i]] = i;
      }
      final positions = <int>[];
      final weights = <num>[];
      for (final v in north) {
        final targets = outTargets[v];
        for (var i = 0; i < targets.length; i++) {
          positions.add(southPos[targets[i]]);
          weights.add(outWeights[v][i]);
        }
      }
      // Sort entries by position; entries with equal positions do not
      // count against each other, so their relative order is irrelevant.
      final idx = List<int>.generate(positions.length, (i) => i)
        ..sort((a, b) => positions[a].compareTo(positions[b]));
      var firstIndex = 1;
      while (firstIndex < south.length) {
        firstIndex <<= 1;
      }
      final tree = List<num>.filled(2 * firstIndex - 1, 0);
      firstIndex -= 1;
      for (final k in idx) {
        var index = positions[k] + firstIndex;
        final weight = weights[k];
        tree[index] += weight;
        num weightSum = 0;
        while (index > 0) {
          if ((index % 2) != 0) weightSum += tree[index + 1];
          index = (index - 1) >> 1;
          tree[index] += weight;
        }
        cc += (weight * weightSum).toInt();
      }
    }
    return cc;
  }
}

/// [buildLayerGraph] as a [IndexedLayerGraph]: same node order, parents, edges and
/// cluster labels.
IndexedLayerGraph _buildIndexedLayerGraph(
  Graph g,
  Map<String, int> index,
  int rootId,
  int rank,
  Relationship ship,
  List<String> nodesInRank,
) {
  final lg = IndexedLayerGraph(rootId);
  for (var v in nodesInRank) {
    Props node = g.node(v);
    if (!(node.getI2(rankK) == rank ||
        (node.getD2(minRankK) ?? double.nan) <= rank &&
            rank <= (node.getD2(maxRankK) ?? double.nan))) {
      continue;
    }
    final id = index[v]!;
    final parentName = g.parent(v);
    final parent = parentName == null ? rootId : index[parentName]!;
    lg.parent[id] = parent;
    // A parent first seen here is a node of the layer graph with no parent;
    // the root never has one.
    lg.children.putIfAbsent(parent, () => []).add(id);

    final sources = lg.inSources.putIfAbsent(id, () => []);
    final weights = lg.inWeights.putIfAbsent(id, () => []);
    for (var e
        in (ship == Relationship.inEdges ? g.inEdges(v) : g.outEdges(v)) ??
            const <Edge>[]) {
      final u = index[e.v == v ? e.w : e.v]!;
      final w = g.edge2(e).getD(weightK);
      final at = sources.indexOf(u);
      if (at < 0) {
        sources.add(u);
        weights.add(w);
      } else {
        weights[at] = w + weights[at];
      }
    }

    // sortSubgraph reads borderLeft/borderRight from the layer graph label:
    // a one-element list for clusters, the full list of `g` otherwise.
    List<dynamic>? bl, br;
    if (node.hasOwn(minRankK)) {
      lg.ownLabel.add(id);
      bl = [node.get<List<dynamic>>(borderLeftK)[rank]];
      br = [node.get<List<dynamic>>(borderRightK)[rank]];
    } else {
      bl = node.get2<List<dynamic>>(borderLeftK);
      br = node.get2<List<dynamic>>(borderRightK);
    }
    final blName = bl != null && bl.isNotEmpty ? bl.first as String : null;
    final brName = br != null && br.isNotEmpty ? br.first as String : null;
    if (blName != null || brName != null) {
      lg.borders[id] = (
        blName == null ? null : index[blName]!,
        brName == null ? null : index[brName]!,
      );
    }
  }
  return lg;
}
