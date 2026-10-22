#!/usr/bin/env bash
# Run from any directory; CI and release validation use the same commands.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
flutter analyze --fatal-infos
(cd packages/elk && flutter test)
(cd packages/mermaid_core && flutter test)
(cd packages/mermaid_flutter && flutter test)
# The parity corpus generator under apps/demo/tool is an explicit macOS-only
# evidence command. CI runs the demo's real test directory.
flutter test apps/demo/test
flutter test apps/website
(cd packages/elk && flutter pub publish --dry-run)
(cd packages/mermaid_core && flutter pub publish --dry-run)
(cd packages/mermaid_flutter && flutter pub publish --dry-run)
