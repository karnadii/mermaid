import 'package:mermaid_core/src/vendor/dagre/src/model/graph_label.dart';
import 'package:mermaid_core/src/vendor/dagre/src/model/props.dart';
import '../graph/graph.dart';
import '../model/enums/relationship.dart';
import '../util/util.dart';

/// Nodes in each rank they take part in, in `g.nodes` order: a node is in
/// rank r when its rank is r or r is within its minRank..maxRank span.
/// buildLayerGraph used to scan every node for every rank.
Map<int, List<String>> nodesByRank(Graph g) {
  final byRank = <int, List<String>>{};
  void add(int r, String v) {
    final list = byRank.putIfAbsent(r, () => []);
    if (list.isEmpty || list.last != v) list.add(v);
  }

  for (var v in g.nodesIterable) {
    Props node = g.node(v);
    final rank = node.getI2(rankK);
    final minRank = node.getD2(minRankK);
    final maxRank = node.getD2(maxRankK);
    // Collect candidate ranks in ascending order, so a node that matches
    // both conditions for one rank is added once.
    final ranks = <int>{
      ?rank,
      if (minRank != null && maxRank != null && minRank.isFinite && maxRank.isFinite)
        for (var r = minRank.ceil(); r <= maxRank; r++) r,
    };
    for (final r in ranks) {
      add(r, v);
    }
  }
  return byRank;
}

Graph buildLayerGraph(Graph g, int rank, Relationship ship, [List<String>? nodesInRank]) {
  String root = createLayerRootName(g);
  Graph result = Graph(isCompound: true);
  GraphLabel gp = GraphLabel();
  gp[rootK] = root;
  result.label = gp;
  result.setDefaultNodePropsFun((v) {
    return g.nodeNull(v);
  });

  for (var v in nodesInRank ?? g.nodes) {
    Props node = g.node(v);
    String? parent = g.parent(v);
    if (node.getI2(rankK) == rank ||
        (node.getD2(minRankK) ?? double.nan) <= rank && rank <= (node.getD2(maxRankK) ?? double.nan)) {
      result.setNode(v);
      result.setParent(v, parent ?? root);
      List<Edge> tmpList = (ship == Relationship.inEdges ? g.inEdges(v) : g.outEdges(v)) ?? [];

      for (var e in tmpList) {
        String u = e.v == v ? e.w : e.v;
        Props? edge = result.edgeNull(u, v);
        num weight = edge?.getD2(weightK) ?? 0;

        Props ep = Props();
        ep[weightK] = (g.edge2(e)).getD(weightK) + weight;
        result.setEdge2(u, v, value: ep);
      }
      if (node.hasOwn(minRankK)) {
        Props ps = Props();
        ps[borderLeftK] = [node.get<List<dynamic>>(borderLeftK)[rank]];
        ps[borderRightK] = [node.get<List<dynamic>>(borderRightK)[rank]];
        result.setNode(v, ps);
      }
    }
  }
  return result;
}

/// Takes a fresh id from the shared uniqueId counter, like dagre.js.
String createLayerRootName(Graph g) {
  String v = uniqueId('_root');
  while (g.hasNode(v)) {
    v = uniqueId('_root');
  }
  return v;
}
