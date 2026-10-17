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
  _IndexedSimplex(this.g) : names = g.nodes, n = g.nodeCount {
    final index = <String, int>{};
    for (var i = 0; i < n; i++) {
      index[names[i]] = i;
    }
    rank = List<double>.generate(n, (i) => g.node(names[i]).getD(rankK));
    for (var i = 0; i < n; i++) {
      inEdges.add([]);
      outEdges.add([]);
      treeAdj.add([]);
    }
    for (final e in g.edgesIterable) {
      final id = src.length;
      final v = index[e.v]!, w = index[e.w]!;
      final label = g.edge2(e);
      src.add(v);
      dst.add(w);
      weight.add(label.getD(weightK));
      minLen.add(label.getD(minLenK));
      outEdges[v].add(id);
      inEdges[w].add(id);
    }
  }

  final Graph g;
  final List<String> names;
  final int n;

  late final List<double> rank;
  final List<int> src = [];
  final List<int> dst = [];
  final List<double> weight = [];
  final List<double> minLen = [];
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
    for (var i = 0; i < n; i++) {
      g.node(names[i])[rankK] = rank[i];
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
