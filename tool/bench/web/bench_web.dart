/// Browser entry point: exposes `globalThis.mermaidDartRender(source)` so the
/// JS runner times mermaid_core with the same loop as Pele and mermaid.js.
library;

import 'dart:js_interop';

import 'package:mermaid_bench/timing.dart';

@JS('mermaidDartRender')
external set _mermaidDartRender(JSFunction f);

void main() {
  _mermaidDartRender = ((JSString source) => renderToSvg(source.toDart).toJS).toJS;
}
