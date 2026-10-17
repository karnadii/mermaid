# Benchmark results

Run on 2026-10-18 with `tool/bench/run.sh` (see [README](README.md) for the
method). Lower is better; every value is the median time of one pass over all
diagrams of the case, in milliseconds.

| | |
| --- | --- |
| Machine | Apple M5 Pro, 48 GB, macOS 26.6.2 |
| mermaid_core | commit on `main` after the empty-subgraph fix (0.3.0 + unreleased changes) |
| Dart | 3.12.2, AOT executable and dart2js `-O2` |
| Pele | 1.6.0 on Node 24.19.0 and in Chromium |
| mermaid.js | 12.2.0 in Chromium |
| Chromium | 156.0.8078.4 (Playwright 1.64.1, headless) |

## Headline

| case | mermaid_core 0.3.0 | mermaid_core now | Pele | mermaid.js |
| --- | ---: | ---: | ---: | ---: |
| flowchart sample | 0.288 | 0.040 | 0.037 | 22.5 |
| all 36 samples | 13.0 | 1.6 | 0.97 | 450 |
| tree, 50 nodes | 2.7 | 0.29 | 0.23 | 76 |
| tree, 500 nodes | 28.4 | 3.1 | 2.9 | 912 |
| mesh, 500 nodes + 200 labelled edges | 313 | 16.2 | 8.0 | fails |

mermaid_core columns are native AOT, Pele is on Node, mermaid.js is in
Chromium. The 0.3.0 numbers come from the same harness on the same machine.

## All cases

(n/m) means only n of m diagrams rendered; the time covers those.

| case | mermaid_core AOT | pele Node | mermaid_core (dart2js) Chromium | pele Chromium | mermaid.js Chromium |
| --- | ---: | ---: | ---: | ---: | ---: |
| sample: flowchart | 0.040 | 0.037 | 0.100 | 0.040 | 22.5 |
| sample: subgraphs | 0.101 | 0.035 | 0.250 | 0.032 | 27.5 |
| sample: sequence | 0.026 | 0.021 | 0.050 | 0.022 | 7.7 |
| sample: class | 0.034 | 0.018 | 0.080 | 0.019 | 27.5 |
| sample: state | 0.063 | 0.035 | 0.133 | 0.038 | 29.0 |
| sample: er | 0.031 | 0.015 | 0.067 | 0.017 | 19.6 |
| sample: icons | 0.041 | 0.017 | 0.083 | 0.016 | 19.8 |
| sample: math | 0.174 | 0.019 | 0.375 | 0.020 | 19.3 |
| sample: git | 0.016 | 0.020 | 0.035 | 0.018 | 5.7 |
| sample: requirement | 0.021 | 0.015 | 0.048 | 0.015 | 19.1 |
| sample: c4 | 0.032 | 0.013 | 0.047 | 0.013 | 5.0 |
| sample: block | 0.020 | 0.009 | 0.018 | 0.008 | 9.9 |
| sample: architecture | 0.030 | 0.018 | 0.047 | 0.015 | 7.9 |
| sample: kanban | 0.012 | 0.007 | 0.016 | 0.008 | 9.3 |
| sample: cynefin | 0.013 | 0.005 (0/1) | 0.031 | 0.003 (0/1) | 1.1 (0/1) |
| sample: ishikawa | 0.008 | 0.007 | 0.020 | 0.008 | 2.8 |
| sample: eventmodeling | 0.009 | 0.014 | 0.020 | 0.012 | 2.5 |
| sample: railroad | 0.008 | 0.003 (0/1) | 0.017 | 0.002 (0/1) | 1.0 (0/1) |
| sample: pie | 0.008 | 0.008 | 0.021 | 0.008 | 2.7 |
| sample: quadrant | 0.011 | 0.008 | 0.019 | 0.009 | 2.4 |
| sample: xychart | 0.018 | 0.011 | 0.033 | 0.012 | 4.6 |
| sample: gantt | 0.023 | 0.018 | 0.043 | 0.019 | 3.4 |
| sample: journey | 0.012 | 0.011 | 0.030 | 0.011 | 3.6 |
| sample: timeline | 0.016 | 0.010 | 0.033 | 0.010 | 4.5 |
| sample: sankey | 0.022 | 0.016 | 0.090 | 0.016 | 3.9 |
| sample: packet | 0.016 | 0.016 | 0.037 | 0.015 | 1.4 |
| sample: mindmap | 0.022 | 0.011 | 0.046 | 0.011 | 19.6 |
| sample: radar | 0.010 | 0.015 | 0.020 | 0.013 | 1.5 |
| sample: treemap | 0.010 | 0.016 | 0.023 | 0.013 | 3.1 |
| sample: venn | 0.009 | 0.032 | 0.015 | 0.043 | 1.6 |
| sample: wardley | 0.011 | 0.010 | 0.019 | 0.010 | 1.6 |
| sample: dark | 0.040 | 0.034 | 0.089 | 0.033 | 23.2 |
| sample: forest | 0.070 | 0.037 | 0.160 | 0.033 | 25.9 |
| sample: custom | 0.067 | 0.037 | 0.164 | 0.034 | 25.5 |
| sample: handdrawn | 0.161 | 0.039 | 0.350 | 0.037 | 27.6 |
| sample: styled | 0.039 | 0.034 | 0.075 | 0.029 | 22.2 |
| samples: all 36 | 1.6 | 0.968 (34/36) | 3.2 | 0.900 (34/36) | 450.5 (34/36) |
| tree: 50 nodes | 0.294 | 0.227 | 0.667 | 0.211 | 76.3 |
| mesh: 50 nodes, 20 extra labelled edges | 0.631 | 0.588 | 1.4 | 0.550 | 98.2 |
| tree: 500 nodes | 3.1 | 2.9 | 6.9 | 2.7 | 911.7 |
| mesh: 500 nodes, 200 extra labelled edges | 16.2 | 8.0 | 33.0 | 7.5 | 6.9 (0/1) |

## Notes

- Not like for like: Pele prints `math` labels as TeX text instead of
  typesetting them with KaTeX and does not draw the `handdrawn` look.
- Pele and mermaid.js fail on `cynefin` and `railroad`; mermaid.js fails on
  the 500-node mesh (more edges than its default limit).
- mermaid.js measures text in the DOM; mermaid_core and Pele use font metric
  tables, so their work per label is smaller.
- The dart2js build in Chromium runs about 2x slower than the AOT build; the
  web runner checks that it draws the same SVG as the native build.
