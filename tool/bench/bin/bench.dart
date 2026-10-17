/// Native benchmark runner.
///
///   dart run bin/bench.dart --corpus build/corpus.json
///       writes the shared corpus that the JS runners read.
///   dart compile exe bin/bench.dart -o build/bench && build/bench
///       times mermaid_core (AOT) and prints JSON results to stdout.
library;

import 'dart:convert';
import 'dart:io';

import 'package:mermaid_bench/corpus.dart';
import 'package:mermaid_bench/timing.dart';

void main(List<String> args) {
  final corpus = buildCorpus();
  final corpusAt = args.indexOf('--corpus');
  if (corpusAt >= 0) {
    File(args[corpusAt + 1])
      ..createSync(recursive: true)
      ..writeAsStringSync(jsonEncode([for (final c in corpus) c.toJson()]));
    return;
  }

  // Optimizations must not change the output: --snapshot writes every
  // case's SVG, --verify compares against a snapshot written earlier.
  for (final mode in ['--snapshot', '--verify']) {
    final at = args.indexOf(mode);
    if (at < 0) continue;
    final dir = Directory(args[at + 1]);
    var changed = 0;
    // The mermaid_core fixtures widen the check beyond the timed corpus.
    final fixtures = Directory('../../packages/mermaid_core/test/fixtures')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.mmd'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final checked = [
      ...corpus,
      for (final f in fixtures)
        BenchCase('fixture: ${f.path.split('/fixtures/').last}',
            [f.readAsStringSync()]),
    ];
    for (final c in checked) {
      final file = File(
          '${dir.path}/${c.name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')}.svg');
      final svg = [
        for (final src in c.inputs)
          try_(() => renderToSvg(src)),
      ].join('\n');
      if (mode == '--snapshot') {
        file
          ..createSync(recursive: true)
          ..writeAsStringSync(svg);
      } else if (!file.existsSync() || file.readAsStringSync() != svg) {
        changed++;
        stderr.writeln('changed: ${c.name}');
      }
    }
    if (mode == '--verify') {
      stderr.writeln(changed == 0
          ? 'all ${checked.length} cases identical'
          : '$changed of ${checked.length} cases changed');
      exitCode = changed == 0 ? 0 : 1;
    }
    return;
  }

  final only = args.where((a) => !a.startsWith('-')).toList();
  final results = <Map<String, Object>>[];
  for (final c in corpus) {
    if (only.isNotEmpty && !only.any(c.name.contains)) continue;
    final t = time(c.inputs);
    stderr.writeln('${c.name.padRight(48)} '
        '${t.medianMs.toStringAsFixed(3).padLeft(10)} ms'
        '${t.rendered == c.inputs.length ? '' : '  (${t.rendered}/${c.inputs.length} rendered)'}');
    results.add({
      'case': c.name,
      'ms': t.medianMs,
      'rendered': t.rendered,
      'diagrams': c.inputs.length,
    });
  }
  stdout.writeln(jsonEncode(results));
}

String try_(String Function() f) {
  try {
    return f();
  } catch (e) {
    return 'error: $e';
  }
}
