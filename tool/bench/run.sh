#!/usr/bin/env bash
# Runs the full benchmark: mermaid_core (AOT and dart2js) vs Pele and mermaid.js.
# Usage: tool/bench/run.sh [--skip-mermaid]
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
dart run bin/bench.dart --corpus build/corpus.json
dart compile exe bin/bench.dart -o build/bench >/dev/null
dart compile js -O2 web/bench_web.dart -o build/bench_web.js >/dev/null
[ -d js/node_modules ] || npm ci --prefix js
# The web build must draw exactly what the native build draws.
dart run bin/bench.dart --snapshot build/golden
node js/bench.mjs build/corpus.json build/bench_web.js --verify build/golden
build/bench > build/dart_aot.json
node js/bench.mjs build/corpus.json build/bench_web.js "$@" > build/js.json
node js/report.mjs build/dart_aot.json build/js.json | tee build/report.md
