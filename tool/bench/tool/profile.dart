/// Samples the Dart VM CPU profiler while one corpus case renders in a loop
/// and prints the functions with the most self and inclusive time.
///
///   dart --profiler run tool/profile.dart "mesh: 500" [seconds]
library;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate' as iso;

import 'package:mermaid_bench/corpus.dart';
import 'package:mermaid_bench/timing.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service_io.dart';

Future<void> main(List<String> args) async {
  final filter = args.isEmpty ? 'mesh: 500' : args.first;
  final seconds = args.length > 1 ? int.parse(args[1]) : 5;
  final c = buildCorpus().firstWhere((c) => c.name.contains(filter));

  final info = await Service.controlWebServer(enable: true, silenceOutput: true);
  final ws = info.serverWebSocketUri!;
  final vm = await vmServiceConnectUri(ws.toString());
  final isolateId = Service.getIsolateId(iso.Isolate.current)!;

  // Warm up the JIT before sampling.
  for (var i = 0; i < 20; i++) {
    c.inputs.forEach(renderToSvg);
  }
  await vm.clearCpuSamples(isolateId);
  final start = (await vm.getVMTimelineMicros()).timestamp!;
  final sw = Stopwatch()..start();
  var runs = 0;
  while (sw.elapsed.inSeconds < seconds) {
    c.inputs.forEach(renderToSvg);
    runs++;
  }
  final end = (await vm.getVMTimelineMicros()).timestamp!;
  stderr.writeln('${c.name}: $runs runs, '
      '${(sw.elapsedMicroseconds / runs / 1000).toStringAsFixed(2)} ms/run');

  final samples = await vm.getCpuSamples(isolateId, start, end - start);
  final fns = samples.functions!;
  final total = samples.sampleCount!;
  final self = <int, int>{};
  final incl = <int, int>{};
  for (final s in samples.samples!) {
    final stack = s.stack!;
    if (stack.isEmpty) continue;
    self.update(stack.first, (v) => v + 1, ifAbsent: () => 1);
    for (final f in stack.toSet()) {
      incl.update(f, (v) => v + 1, ifAbsent: () => 1);
    }
  }
  String name(int i) {
    final f = fns[i].function;
    final n = f is FuncRef ? _qualified(f) : (f as dynamic).name as String;
    final uri = fns[i].resolvedUrl ?? '';
    final file = uri.split('/').last;
    return '$n  ($file)';
  }

  void table(String title, Map<int, int> m, int n) {
    stdout.writeln('\n$title (of $total samples)');
    final top = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in top.take(n)) {
      final pct = (100 * e.value / total).toStringAsFixed(1).padLeft(5);
      stdout.writeln('$pct%  ${name(e.key)}');
    }
  }

  table('Self time', self, 30);
  table('Inclusive time', incl, 40);
  await vm.dispose();
  exit(0);
}

String _qualified(FuncRef f) {
  final owner = f.owner;
  if (owner is ClassRef) return '${owner.name}.${f.name}';
  if (owner is FuncRef) return '${_qualified(owner)}.${f.name}';
  return f.name ?? '?';
}
