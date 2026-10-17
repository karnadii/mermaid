part of 'network_simplex.dart';

/// Network simplex over integer indices instead of string-keyed graphs.
///
/// It makes the same pivots as the reference code above, so the ranks are
/// identical:
/// - the feasible tree adds nodes and edges in the same order (tightTree
///   walks in-edges then out-edges of each node in reverse, and
///   _findMinSlackEdge takes the first edge with the smallest slack),
/// - the leaving edge is the first tree edge, in insertion order, with a
///   negative cut value; an exchanged edge moves to the end of that order,
/// - the entering edge is the first graph edge with the smallest slack,
/// - all walks are rooted at the first tree node.
/// Cut values, subtree membership and the rank update depend only on the
/// tree and its root, not on the walk order, so those parts are free to use
/// plain arrays.
class _IndexedSimplex {
  _IndexedSimplex(this.rank, this.src, this.dst, this.weight, this.minLen)
    : n = rank.length {
    for (var i = 0; i < n; i++) {
      inEdges.add([]);
      outEdges.add([]);
      treeAdj.add([]);
    }
    for (var e = 0; e < src.length; e++) {
      outEdges[src[e]].add(e);
      inEdges[dst[e]].add(e);
    }
  }

  final int n;

  final List<double> rank;
  final List<int> src;
  final List<int> dst;
  final List<double> weight;
  final List<double> minLen;
  final List<List<int>> inEdges = [];
  final List<List<int>> outEdges = [];

  /// Tree nodes in insertion order, and tree edges as graph edge ids in
  /// insertion order.
  final List<int> treeNodes = [];
  late final List<bool> inTree = List<bool>.filled(n, false);
  final List<int> treeEdges = [];
  final List<List<int>> treeAdj = [];

  late final List<int> parent = List<int>.filled(n, -1);

  /// Graph edge id of the tree edge from a node to its parent.
  late final List<int> parentEdge = List<int>.filled(n, -1);
  late final List<int> low = List<int>.filled(n, 0);
  late final List<int> lim = List<int>.filled(n, 0);

  /// Cut value of the tree edge between a node and its parent.
  late final List<double> cutValue = List<double>.filled(n, 0);

  double slackOf(int e) => rank[dst[e]] - rank[src[e]] - minLen[e];

  void run() {
    if (n == 0) return;
    _feasibleTree();
    _initLowLim();
    _initCutValues();
    while (true) {
      final leave = _leaveEdge();
      if (leave < 0) break;
      final enter = _enterEdge(leave);
      _exchange(leave, enter);
    }
  }

  void _addTreeEdge(int e) {
    treeEdges.add(e);
    treeAdj[src[e]].add(e);
    treeAdj[dst[e]].add(e);
  }

  void _feasibleTree() {
    treeNodes.add(0);
    inTree[0] = true;
    while (_tightTree() < n) {
      var best = -1;
      var bestSlack = double.infinity;
      for (var e = 0; e < src.length; e++) {
        if (inTree[src[e]] == inTree[dst[e]]) continue;
        final s = slackOf(e);
        if (s < bestSlack) {
          bestSlack = s;
          best = e;
        }
      }
      final delta = inTree[src[best]] ? bestSlack : -bestSlack;
      for (final v in treeNodes) {
        rank[v] += delta;
      }
    }
  }

  int _tightTree() {
    final roots = List<int>.of(treeNodes);
    final stack = <int>[];
    for (final root in roots) {
      stack.add(root);
      while (stack.isNotEmpty) {
        final curr = stack.removeLast();
        // nodeEdges() is in-edges then out-edges, visited in reverse.
        final outs = outEdges[curr], ins = inEdges[curr];
        for (var i = outs.length + ins.length - 1; i >= 0; i--) {
          final e = i >= ins.length ? outs[i - ins.length] : ins[i];
          final w = src[e] == curr ? dst[e] : src[e];
          if (inTree[w]) continue;
          final s = slackOf(e);
          if (s.isNaN || s.toInt() == 0) {
            inTree[w] = true;
            treeNodes.add(w);
            _addTreeEdge(e);
            stack.add(w);
          }
        }
      }
    }
    return treeNodes.length;
  }

  /// Assigns parent, low and lim (postorder numbers) from the first tree
  /// node. Also returns the postorder, children before parents.
  List<int> _initLowLim() {
    final root = treeNodes[0];
    final post = <int>[];
    final visited = List<bool>.filled(n, false);
    // Explicit stack of (node, next adjacency index).
    final nodeStack = <int>[root];
    final iterStack = <int>[0];
    visited[root] = true;
    parent[root] = -1;
    parentEdge[root] = -1;
    var nextLim = 1;
    low[root] = nextLim;
    while (nodeStack.isNotEmpty) {
      final top = nodeStack.length - 1;
      final v = nodeStack[top];
      final adj = treeAdj[v];
      final i = iterStack[top];
      if (i < adj.length) {
        iterStack[top] = i + 1;
        final e = adj[i];
        final w = src[e] == v ? dst[e] : src[e];
        if (visited[w]) continue;
        visited[w] = true;
        parent[w] = v;
        parentEdge[w] = e;
        low[w] = nextLim;
        nodeStack.add(w);
        iterStack.add(0);
      } else {
        lim[v] = nextLim++;
        post.add(v);
        nodeStack.removeLast();
        iterStack.removeLast();
      }
    }
    _postorder = post;
    return post;
  }

  List<int> _postorder = const [];

  void _initCutValues() {
    final post = _postorder;
    for (var i = 0; i < post.length - 1; i++) {
      final child = post[i];
      cutValue[child] = _calcCutValue(child);
    }
  }

  double _calcCutValue(int child) {
    final par = parent[child];
    final treeEdge = parentEdge[child];
    final childIsTail = src[treeEdge] == child;
    var cut = weight[treeEdge];
    void visit(int e) {
      final isOut = src[e] == child;
      final other = isOut ? dst[e] : src[e];
      if (other == par) return;
      final pointsToHead = isOut == childIsTail;
      final w = weight[e];
      cut += pointsToHead ? w : -w;
      // A tree edge to `other` other than the parent edge leads to a child.
      if (parent[other] == child && parentEdge[other] == e) {
        final otherCut = cutValue[other];
        cut += pointsToHead ? -otherCut : otherCut;
      }
    }

    for (final e in inEdges[child]) {
      visit(e);
    }
    for (final e in outEdges[child]) {
      visit(e);
    }
    return cut;
  }

  /// Child endpoint of tree edge [e].
  int _childOf(int e) =>
      parent[src[e]] == dst[e] && parentEdge[src[e]] == e ? src[e] : dst[e];

  int _leaveEdge() {
    for (final e in treeEdges) {
      if (cutValue[_childOf(e)] < 0) return e;
    }
    return -1;
  }

  bool _isDescendant(int v, int root) =>
      low[root] <= lim[v] && lim[v] <= lim[root];

  int _enterEdge(int leave) {
    // [leave] is a graph edge, so src -> dst is already its direction.
    final v = src[leave], w = dst[leave];
    var tail = v;
    var flip = false;
    if (lim[v] > lim[w]) {
      tail = w;
      flip = true;
    }
    var best = -1;
    var bestSlack = 0.0;
    for (var e = 0; e < src.length; e++) {
      if (flip == _isDescendant(src[e], tail) &&
          flip != _isDescendant(dst[e], tail)) {
        final s = slackOf(e);
        if (best < 0 || s < bestSlack) {
          best = e;
          bestSlack = s;
        }
      }
    }
    return best;
  }

  void _exchange(int leave, int enter) {
    treeEdges.remove(leave);
    treeAdj[src[leave]].remove(leave);
    treeAdj[dst[leave]].remove(leave);
    _addTreeEdge(enter);
    final post = _initLowLim();
    _initCutValues();
    // Ranks from the root down: reverse postorder visits parents first.
    for (var i = post.length - 2; i >= 0; i--) {
      final v = post[i];
      final e = parentEdge[v];
      // Edge v -> parent: rank(v) = rank(parent) - minLen, else + minLen.
      rank[v] = src[e] == v
          ? rank[parent[v]] - minLen[e]
          : rank[parent[v]] + minLen[e];
    }
  }
}

/// Ranks [n] nodes with network simplex on indices, as
/// `networkSimplex(asNonCompoundGraph(g))` does: parallel edges merged in
/// edge order (weights summed, minLen the maximum, as simplify() does),
/// longest-path ranks, then the pivots. Returns null for a cyclic graph,
/// where the reference code must run.
List<double>? networkSimplexRanks(
  int n,
  List<int> edgeV,
  List<int> edgeW,
  List<double> edgeWeight,
  List<double> edgeMinLen,
) {
  if (n == 0) return null;
  final src = <int>[], dst = <int>[];
  final weight = <double>[], minLen = <double>[];
  final edgeOf = <int, int>{};
  for (var i = 0; i < edgeV.length; i++) {
    final v = edgeV[i], w = edgeW[i];
    final at = edgeOf[v * n + w];
    if (at == null) {
      edgeOf[v * n + w] = src.length;
      src.add(v);
      dst.add(w);
      weight.add(0 + edgeWeight[i]);
      minLen.add(math.max(1.0, edgeMinLen[i]));
    } else {
      weight[at] = weight[at] + edgeWeight[i];
      minLen[at] = math.max(minLen[at], edgeMinLen[i]);
    }
  }
  // longestPath: rank(v) = min over out-edges of rank(w) - minLen, 0 for
  // sinks. The values do not depend on the visit order.
  final outs = List<List<int>>.generate(n, (_) => []);
  for (var e = 0; e < src.length; e++) {
    outs[src[e]].add(e);
  }
  final rank = List<double>.filled(n, 0);
  final state = List<int>.filled(n, 0); // 0 new, 1 open, 2 done
  final stack = <int>[];
  for (var root = 0; root < n; root++) {
    if (state[root] != 0) continue;
    stack.add(root);
    while (stack.isNotEmpty) {
      final v = stack.last;
      if (state[v] == 0) {
        state[v] = 1;
        for (final e in outs[v]) {
          final w = dst[e];
          if (state[w] == 1) return null;
          if (state[w] == 0) stack.add(w);
        }
      } else {
        stack.removeLast();
        if (state[v] == 2) continue;
        state[v] = 2;
        double? r;
        for (final e in outs[v]) {
          final x = rank[dst[e]] - minLen[e];
          r = r == null ? x : math.min(r, x);
        }
        rank[v] = (r == null || r.isInfinite || r.isNaN) ? 0 : r;
      }
    }
  }
  _IndexedSimplex(rank, src, dst, weight, minLen).run();
  return rank;
}
