/// Timing loop shared by the native and the browser runners. It is a copy of
/// `time()` in Pele's `scripts/bench.mjs`: one warm-up pass, then repeat for
/// a 300 ms budget (at least 5, at most 2000 samples) and report the median.
library;

import 'package:mermaid_core/mermaid_core.dart';

const _mermaid = Mermaid(measurer: ApproximateTextMeasurer());

/// Source to SVG string, the same unit of work as Pele's `render()`.
String renderToSvg(String source) =>
    renderSceneToSvg(_mermaid.render(source));

class Timing {
  const Timing(this.medianMs, this.rendered, this.samples);

  final double medianMs;
  final int rendered;
  final int samples;
}

Timing time(List<String> inputs, {double budgetMs = 300}) {
  int run() {
    var done = 0;
    for (final src in inputs) {
      try {
        renderToSvg(src);
        done++;
      } catch (_) {
        continue;
      }
    }
    return done;
  }

  final done = run();
  var budget = budgetMs;
  final samples = <double>[];
  final sw = Stopwatch();
  while (budget > 0 || samples.length < 5) {
    sw
      ..reset()
      ..start();
    run();
    sw.stop();
    final ms = sw.elapsedMicroseconds / 1000;
    samples.add(ms);
    budget -= ms;
    if (samples.length >= 2000) break;
  }
  samples.sort();
  return Timing(samples[samples.length >> 1], done, samples.length);
}
