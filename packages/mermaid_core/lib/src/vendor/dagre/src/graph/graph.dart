// ignore_for_file: strict_top_level_inference
import 'package:mermaid_core/src/vendor/dagre/src/model/props.dart';

import '../model/graph_label.dart';

/// Edge key: (v, w, name). A record hashes the cached string hashes, where
/// the original `v + "\x01" + w + "\x01" + name` key built and hashed a new
/// string on every edge lookup.
typedef EdgeKey = (String, String, String);

/// Everything the graph keeps for one node, so one lookup by id reaches the
/// label and the adjacency. Each map keeps insertion order, which the layout
/// depends on, exactly as the separate per-node maps of graphlib did.
class _Node {
  _Node(this.label);

  Props? label;
  final Map<EdgeKey, Edge> inEdges = {};
  final Map<EdgeKey, Edge> outEdges = {};

  /// Predecessor/successor id -> number of parallel edges.
  final Map<String, int> preds = {};
  final Map<String, int> sucs = {};
}

/// An edge and its label. [Edge._entry] points back here, so [Graph.edge2]
/// on an edge object taken from this graph needs no lookup.
class _EdgeEntry {
  _EdgeEntry(this.graph, this.key, this.edge, this.label);

  final Graph graph;
  final EdgeKey key;
  final Edge edge;
  Props? label;
  bool removed = false;
}

class Graph {
  static const String _defaultEdgeId = "\x00";
  static const String _graphNodeId = "\x00";
  final bool isDirected;
  final bool isMultiGraph;
  final bool isCompound;

  // 图本身的属性
  GraphLabel? _label;

  GraphLabel get label => _label!;

  GraphLabel? get label2 => _label;

  set label(GraphLabel? newLabel) {
    _label = newLabel;
  }

  final Map<String, _Node> _nodes = {};

  final Map<EdgeKey, _EdgeEntry> _edges = {};

  // nodeId -> parent id
  Map<String, String> _parent = {};

  Map<String, Map<String, bool>> _children = {};

  Props? Function(String)? _defaultNodeLabelFun;

  Props Function(String, String, String?)? _defaultEdgeLabelFun;

  Graph({
    this.isDirected = true,
    this.isMultiGraph = false,
    this.isCompound = false,
  }) {
    if (isCompound) {
      _parent = {};
      _children = {};
      _children[_graphNodeId] = {};
    }
  }

  Graph setDefaultNodePropsFun(Props? Function(String) newDefault) {
    _defaultNodeLabelFun = newDefault;
    return this;
  }

  Graph setDefaultEdgeLabelFun(
    Props Function(String, String, String?) newDefault,
  ) {
    _defaultEdgeLabelFun = newDefault;
    return this;
  }

  Graph setDefaultNodeLabel(String label) {
    var type = Props()..value = label;
    _defaultNodeLabelFun = (v) => type;
    return this;
  }

  Graph setDefaultEdgeLabel(String newDefault) {
    var type = Props()..value = newDefault;
    _defaultEdgeLabelFun = (a, b, c) => type;
    return this;
  }

  int get nodeCount => _nodes.length;

  List<String> get nodes => _nodes.keys.toList();

  Iterable<String> get nodesIterable => _nodes.keys;

  List<String> get sources => [
    for (final e in _nodes.entries)
      if (e.value.inEdges.isEmpty) e.key,
  ];

  List<String> get sinks => [
    for (final e in _nodes.entries)
      if (e.value.outEdges.isEmpty) e.key,
  ];

  Graph setNodes(List<String> vs, [Props? value]) {
    for (var v in vs) {
      setNode(v, value);
    }
    return this;
  }

  Graph setNode(String v, [Props? value]) {
    var node = _nodes[v];
    if (node != null) {
      if (value != null) {
        node.label = value;
      }
      return this;
    }
    _nodes[v] = _Node(value ?? _defaultNodeLabelFun?.call(v));
    if (isCompound) {
      _parent[v] = _graphNodeId;
      _children[v] = {};
      Map<String, bool> m = _children[_graphNodeId] ?? {};
      _children[_graphNodeId] = m;
      m[v] = true;
    }
    return this;
  }

  Props node(String nodeId) {
    return _nodes[nodeId]!.label!;
  }

  Props? nodeNull(String nodeId) {
    return _nodes[nodeId]?.label;
  }

  Graph setParent(String id, [String? parent]) {
    if (!isCompound) {
      throw StateError("Cannot set parent in a non-compound graph");
    }
    if (parent == null) {
      parent = _graphNodeId;
    } else {
      String? ancestor = parent;
      while (ancestor != null) {
        ancestor = this.parent(ancestor);
        if (ancestor == id) {
          throw StateError(
            'Setting  $parent   as parent of $id  would create a cycle',
          );
        }
      }
      setNode(parent);
    }
    setNode(id);
    _removeFromParentsChildList(id);
    _parent[id] = parent;

    Map<String, bool> m = _children[parent] ?? {};
    _children[parent] = m;
    m[id] = true;
    return this;
  }

  void _removeFromParentsChildList(String? v) {
    _children[_parent[v]]?.remove(v);
  }

  String? parent(String v) {
    if (isCompound) {
      var parent = _parent[v];
      if (parent != _graphNodeId) {
        return parent;
      }
    }
    return null;
  }

  List<String>? predecessors(String v) {
    return _nodes[v]?.preds.keys.toList();
  }

  List<String>? successors(String v) {
    return _nodes[v]?.sucs.keys.toList();
  }

  bool isLeaf(v) {
    List<String>? neighborsv;
    if (isDirected) {
      neighborsv = successors(v);
    } else {
      neighborsv = neighbors(v);
    }
    return neighborsv == null || neighborsv.isEmpty;
  }

  ///根据EdgeObj 对象获取对应的Value
  Props edge(String v, String w, [String? name]) {
    return edgeNull(v, w, name)!;
  }

  Props edge2(Edge obj) {
    return edge2Null(obj)!;
  }

  Props? edgeNull(String v, String w, [String? name]) {
    return _edges[edgeArgsToId(isDirected, v, w, name)]?.label;
  }

  // Like graphlib's edge(obj): throws when the edge is not in the graph.
  Props? edge2Null(Edge obj) {
    final entry = obj._entry;
    if (entry != null && identical(entry.graph, this) && !entry.removed) {
      return entry.label!;
    }
    return edge(obj.v, obj.w, obj.id);
  }

  int get edgeCount => _edges.length;

  ///返回所有的EdgeObj对象
  List<Edge> get edges {
    return [for (final e in _edges.values) e.edge];
  }

  Iterable<Edge> get edgesIterable {
    return _edges.values.map((e) => e.edge);
  }

  bool hasEdge(Edge edge) {
    return _edges.containsKey(edgeObjToId(isDirected, edge));
  }

  bool hasEdge2(String v, String w, [String? id]) {
    return _edges.containsKey(edgeArgsToId(isDirected, v, w, id));
  }

  // Vendored fix: graphlib's inEdges returns undefined only when the node
  // does not exist; for an existing node with no incoming edges `_in[v]` is
  // an empty object (truthy), so it returns an empty array. The original
  // port added an `isNotEmpty` check, returning null for source nodes. That
  // made nodeEdges() drop a source node's out-edges entirely, so
  // feasibleTree's tightTree could never expand through the nesting root —
  // an infinite loop on graphs with multiple disconnected components.
  List<Edge>? inEdges(String v, [String? u]) {
    var node = _nodes[v];
    if (node == null) {
      return null;
    }
    if (u == null) {
      return node.inEdges.values.toList();
    }
    return [
      for (final edge in node.inEdges.values)
        if (edge.v == u) edge,
    ];
  }

  List<Edge>? outEdges(String v, [String? w]) {
    var node = _nodes[v];
    if (node == null) {
      return null;
    }
    if (w == null) {
      return node.outEdges.values.toList();
    }
    return [
      for (final edge in node.outEdges.values)
        if (edge.w == w) edge,
    ];
  }

  Graph removeEdge(String v, String w, [String? name]) {
    var entry = _edges.remove(edgeArgsToId(isDirected, v, w, name));
    if (entry != null) {
      _detachEdge(entry);
    }
    return this;
  }

  void _detachEdge(_EdgeEntry entry) {
    entry.removed = true;
    var v = entry.edge.v;
    var w = entry.edge.w;
    var nodeV = _nodes[v];
    var nodeW = _nodes[w];
    decrementOrRemoveEntry(nodeW?.preds, v);
    decrementOrRemoveEntry(nodeV?.sucs, w);
    nodeW?.inEdges.remove(entry.key);
    nodeV?.outEdges.remove(entry.key);
  }

  Graph removeEdge2(Edge? v) {
    if (v == null) {
      return this;
    }
    return removeEdge(v.v, v.w, v.id);
  }

  Graph setEdge(Edge edge, [Props? value]) {
    return _setEdgeInner(edge.v, edge.w, edge.id, value);
  }

  Graph setEdge2(String v, String w, {String? name, Props? value}) {
    return _setEdgeInner(v, w, name, value);
  }

  Graph _setEdgeInner(String v, String w, String? name, Props? value) {
    var e = edgeArgsToId(isDirected, v, w, name);
    var existing = _edges[e];
    if (existing != null) {
      if (value != null) {
        existing.label = value;
      }
      return this;
    }
    if (!(name == null || name.isEmpty) && !isMultiGraph) {
      throw StateError("Cannot set a named edge when isMultigraph = false");
    }

    setNode(v);
    setNode(w);
    var label = value ?? _defaultEdgeLabelFun?.call(v, w, name);
    var edgeObj = edgeArgsToObj(isDirected, v, w, name);
    v = edgeObj.v;
    w = edgeObj.w;
    var entry = _EdgeEntry(this, e, edgeObj, label);
    edgeObj._entry = entry;
    _edges[e] = entry;
    var nodeV = _nodes[v]!;
    var nodeW = _nodes[w]!;
    incrementOrInitEntry(nodeW.preds, v);
    incrementOrInitEntry(nodeV.sucs, w);
    nodeW.inEdges[e] = edgeObj;
    nodeV.outEdges[e] = edgeObj;
    return this;
  }

  List<String>? children([String nodeId = _graphNodeId]) {
    if (isCompound) {
      var children = _children[nodeId];
      if (children != null) {
        return children.keys.toList();
      }
    } else if (nodeId == _graphNodeId) {
      return nodes;
    } else if (hasNode(nodeId)) {
      return [];
    }
    return null;
  }

  bool hasNode(String v) {
    return _nodes.containsKey(v);
  }

  List<String>? neighbors(String v) {
    var node = _nodes[v];
    if (node == null) {
      return null;
    }
    Set<String> ds = Set.of(node.preds.keys);
    ds.addAll(node.sucs.keys);
    return ds.toList();
  }

  Graph removeNode(String v) {
    var node = _nodes[v];
    if (node != null) {
      if (isCompound) {
        _removeFromParentsChildList(v);
        _parent.remove(v);
        children(v)?.forEach((child) {
          setParent(child);
        });
        _children.remove(v);
      }
      for (var e in node.inEdges.keys.toList()) {
        var entry = _edges.remove(e);
        if (entry != null) _detachEdge(entry);
      }
      for (var e in node.outEdges.keys.toList()) {
        var entry = _edges.remove(e);
        if (entry != null) _detachEdge(entry);
      }
      _nodes.remove(v);
    }
    return this;
  }

  Graph filterNodes(bool Function(String) filter) {
    var copy = Graph(
      isDirected: isDirected,
      isMultiGraph: isMultiGraph,
      isCompound: isCompound,
    );
    copy.label = label;

    _nodes.forEach((v, value) {
      if (filter(v)) {
        copy.setNode(v, value.label);
      }
    });

    for (var entry in _edges.values) {
      var e = entry.edge;
      if (copy.hasNode(e.v) && copy.hasNode(e.w)) {
        copy.setEdge(e, entry.label!);
      }
    }

    Map<String, String?> parents = {};
    findParent(v) {
      var parent = this.parent(v);
      if (parent == null || copy.hasNode(parent)) {
        parents[v] = parent;
        return parent;
      } else if (parents.containsKey(parent)) {
        return parents[parent];
      } else {
        return findParent(parent);
      }
    }

    if (isCompound) {
      for (var v in copy.nodes) {
        copy.setParent(v, findParent(v));
      }
    }
    return copy;
  }

  Graph setPath(List<String> idList, [Props? value]) {
    for (int i = 1; i < idList.length; i++) {
      String v = idList[i - 1];
      String w = idList[i];
      _setEdgeInner(v, w, null, value);
    }
    return this;
  }

  List<Edge>? nodeEdges(String v, [String? w]) {
    var values = inEdges(v, w);
    if (values != null) {
      var list = outEdges(v, w);
      if (list != null) {
        values.addAll(list);
      }
      return values;
    }
    return null;
  }

  void incrementOrInitEntry(Map<String, int> map, String k) {
    int? v = map[k];
    if (v != null) {
      map[k] = v + 1;
    } else {
      map[k] = 1;
    }
  }

  void decrementOrRemoveEntry(Map<String, int>? map, String k) {
    if (map == null) {
      return;
    }
    int? v = map[k];
    if (v != null) {
      v -= 1;
      map[k] = v;
    }
    if (v == null || v == 0) {
      map.remove(k);
    }
  }

  EdgeKey edgeArgsToId(
    bool isDirected,
    String v_,
    String? w_, [
    String? edgeId,
  ]) {
    String v = v_;
    String w = w_ ?? '';
    if (!isDirected && v.compareTo(w) > 0) {
      var tmp = v;
      v = w;
      w = tmp;
    }
    return (v, w, (edgeId == null || edgeId.isEmpty) ? _defaultEdgeId : edgeId);
  }

  Edge edgeArgsToObj(bool isDirected, String v_, String w_, [String? edgeId]) {
    var v = v_;
    var w = w_;
    int t = v.compareTo(w);
    if (!isDirected && t > 0) {
      var tmp = v;
      v = w;
      w = tmp;
    }
    return Edge(v: v, w: w, id: edgeId);
  }

  EdgeKey edgeObjToId(bool isDirected, Edge obj) {
    return edgeArgsToId(isDirected, obj.v, obj.w, obj.id);
  }
}

class Edge {
  final String v;
  final String w;
  final String? id;

  /// Set on the edge object a graph stores, see [_EdgeEntry].
  _EdgeEntry? _entry;

  Edge({required this.v, required this.w, this.id});

  @override
  String toString() {
    return "id:$id,v:$v,w:$w";
  }
}
