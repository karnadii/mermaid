/// The benchmark corpus: the comparison-site samples plus the generated
/// flowcharts that Pele's own `scripts/bench.mjs` uses, so the numbers can be
/// put next to the ones on pele.run.
library;

import 'package:mermaid_samples/mermaid_samples.dart';

class BenchCase {
  const BenchCase(this.name, this.inputs);

  final String name;
  final List<String> inputs;

  Map<String, Object> toJson() => {'name': name, 'inputs': inputs};
}

/// Same generator as `chain()` in Pele's `scripts/bench.mjs`.
String tree(int n, int fan) {
  final s = StringBuffer('flowchart TD\n');
  for (var i = 1; i < n; i++) {
    final p = (i - 1) ~/ fan;
    s.write('  n$p[Node $p] --> n$i[Node $i]\n');
  }
  return s.toString();
}

/// Same generator as `mesh()` in Pele's `scripts/bench.mjs`, including its
/// LCG, so both sides get byte-identical sources.
String mesh(int n, int extra) {
  final s = StringBuffer('flowchart TD\n');
  var seed = 7;
  double rnd() {
    seed = (seed * 1664525 + 1013904223) & 0xffffffff;
    return seed / 4294967296;
  }

  for (var i = 1; i < n; i++) {
    s.write('  n${(rnd() * i).floor()} --> n$i\n');
  }
  for (var i = 0; i < extra; i++) {
    s.write('  n${(rnd() * n).floor()} -->|label $i| n${(rnd() * n).floor()}\n');
  }
  return s.toString();
}

/// Samples that only exercise a feature the other engines do not have
/// (theme presets on the same flowchart) are kept: they are cheap and still
/// valid Mermaid.
List<BenchCase> buildCorpus() => [
      for (final s in samples) BenchCase('sample: ${s.id}', [s.source]),
      BenchCase('samples: all ${samples.length}',
          [for (final s in samples) s.source]),
      BenchCase('tree: 50 nodes', [tree(50, 3)]),
      BenchCase('mesh: 50 nodes, 20 extra labelled edges', [mesh(50, 20)]),
      BenchCase('tree: 500 nodes', [tree(500, 3)]),
      BenchCase(
          'mesh: 500 nodes, 200 extra labelled edges', [mesh(500, 200)]),
    ];
