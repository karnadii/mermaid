# Render benchmark

Times `mermaid_core` against [mermaid.js](https://mermaid.js.org) and
[Pele](https://pele.run) on the same diagrams.

```console
$ tool/bench/run.sh                  # everything, writes build/report.md
$ tool/bench/run.sh --skip-mermaid   # without mermaid.js (much faster)
```

`run.sh` needs Node and runs `npm ci` in `js/` on first use. Playwright's
Chromium must be installed (`npx playwright install chromium` in `js/`).

## What is measured

One unit of work is source text to an SVG string:

| Engine | Call | Where |
| --- | --- | --- |
| mermaid_core | `renderSceneToSvg(Mermaid(...).render(src))` with `ApproximateTextMeasurer` | native AOT executable, and dart2js in headless Chromium |
| Pele | `render(src).svg` | Node, and headless Chromium |
| mermaid.js | `await mermaid.render(id, src)` | headless Chromium (it needs a DOM) |

Every engine uses the timing loop of Pele's own `scripts/bench.mjs`: one
warm-up pass, then repeated passes for a 300 ms budget (at least 5, at most
2000) and the median pass time. In the browser a sample repeats the pass
until it takes 2 ms, because `performance.now()` is coarsened to about
0.1 ms there.

The corpus (`lib/corpus.dart`) is:

- every sample of the comparison site, one case each, and all of them as one
  case,
- the generated flowcharts of Pele's `bench.mjs` (a 3-ary tree and a random
  mesh with extra labelled edges, 50 and 500 nodes), with the same generators
  and seeds, so the numbers can be put next to the ones on pele.run.

## Caveats

- The engines do not do the same work for every diagram. Pele prints math
  labels as TeX text instead of typesetting them with KaTeX, and does not
  draw the hand-drawn look, so the `math` and `handdrawn` rows are not like
  for like. mermaid.js measures text in the DOM; mermaid_core and Pele use
  font metrics tables.
- mermaid.js and Pele fail on some samples (`cynefin`, `railroad`), and
  mermaid.js on the 500-node mesh (more edges than its default limit). The
  report shows how many diagrams of a case rendered.
- Run nothing else on the machine while timing. For A/B comparisons of one
  change, alternate two executables a few times and compare medians.

## Keeping the output unchanged

Performance changes must not change what is drawn:

```console
$ dart run bin/bench.dart --snapshot build/golden   # before the change
$ dart run bin/bench.dart --verify build/golden     # after it
```

`--verify` compares the SVG of every corpus case and every `.mmd` fixture of
`packages/mermaid_core/test/fixtures`. The web build can differ from the
native one (bitwise operators are 32-bit unsigned under dart2js, for
example), so `run.sh` also renders the corpus with the dart2js build in
Chromium and compares it with the native snapshot:

```console
$ node js/bench.mjs build/corpus.json build/bench_web.js --verify build/golden
``` The dagre port has two
implementations, the string-keyed reference and the indexed pipeline that
runs by default; `packages/mermaid_core/test/dagre_indexed_equivalence_test.dart`
renders random diagrams with both and requires identical SVG.

## Profiling

```console
$ dart --profiler run tool/profile.dart "tree: 500" 6 60
$ CALLERS=Lists.copy dart --profiler run tool/profile.dart "tree: 500"
```

The first prints the functions with the most self and inclusive time while
the case renders in a loop; `CALLERS` also lists who calls a hot function.
