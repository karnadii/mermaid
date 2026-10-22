/// SVG string backend: serializes a [RenderScene] to standalone SVG.
///
/// Pure serialization — every layout/styling decision was already made when
/// the scene was built, so this stays trivially in sync with the Flutter
/// painter. Resolved wrapping is emitted per explicit `\n` line; soft wrap
/// points that a layout leaves implicit are not available to this backend.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../color.dart';
import '../geometry.dart';
import '../ir/scene.dart';
import '../math/katex_fonts.dart';
import '../text/text_style.dart';

String renderSceneToSvg(RenderScene scene) {
  final b = _SvgWriter.reused()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" ')
    ..write('width="${_num(scene.size.width)}" ')
    ..write('height="${_num(scene.size.height)}" ')
    ..write(
      'viewBox="0 0 ${_num(scene.size.width)} ${_num(scene.size.height)}">',
    );
  // Self-contained KaTeX math fonts: embed @font-face only when used.
  if (_usesKatex(scene.nodes)) {
    b.write(_katexFontFaces);
  }
  final bg = scene.background;
  if (bg != null && bg.alpha > 0) {
    b.write('<rect width="100%" height="100%" fill="${_color(bg)}"/>');
  }
  final ids = _IdGen();
  _writeNodes(b, scene.nodes, ids);
  b.write('</svg>');
  final svg = b.toString();
  b.release();
  return svg;
}

/// The embedded KaTeX fonts, built once: the base64 bodies are large.
const _katexFontFaces =
    '<defs><style>'
    '@font-face{font-family:"KaTeX_Main";src:url(data:font/ttf;'
    'base64,$katexMainRegularTtfBase64) format("truetype");}'
    '@font-face{font-family:"KaTeX_Math";src:url(data:font/ttf;'
    'base64,$katexMathItalicTtfBase64) format("truetype");}'
    '</style></defs>';

/// The output builder. [StringBuffer] costs a call per character code and a
/// part per short string, and a string built from a [Uint16List] costs a scan
/// per character; this appends Latin-1 code units to one [Uint8List], which
/// becomes a string with one copy.
class _SvgWriter {
  _SvgWriter([int capacity = 4096]) : _buf = Uint8List(capacity);

  /// A writer on the buffer kept from the previous document, so a large
  /// diagram does not allocate and copy its buffer again on every render.
  /// Hand the buffer back with [release].
  _SvgWriter.reused() : _buf = _spare ?? Uint8List(4096) {
    _spare = null;
  }

  /// The buffer of the last released writer.
  static Uint8List? _spare;

  /// Buffers above this size are not kept, so one huge diagram does not hold
  /// its memory for the rest of the process.
  static const _maxSpare = 1 << 20;

  /// Keeps this writer's buffer for the next [_SvgWriter.reused]. The writer
  /// must not be used after this.
  void release() {
    if (_buf.length <= _maxSpare) _spare = _buf;
  }

  Uint8List _buf;
  int _len = 0;

  /// Earlier output, set once a long string (the embedded fonts) or a string
  /// outside Latin-1 was added as its own part instead of being copied.
  List<String>? _parts;

  static const _longString = 1024;

  void write(String s) {
    final n = s.length;
    if (n > _longString) return _addPart(s);
    if (_len + n > _buf.length) _grow(n);
    final buf = _buf;
    var len = _len;
    for (var i = 0; i < n; i++) {
      final c = s.codeUnitAt(i);
      if (c > 0xff) return _addPart(s);
      buf[len++] = c;
    }
    _len = len;
  }

  /// Appends `s.substring(start, end)` escaped like [_escapeText] or, for an
  /// [attribute] value, like [_escapeAttr], without building the escaped
  /// string. Returns false when [s] is outside Latin-1 and was added as a
  /// separate part instead of being put into the buffer.
  bool writeEscaped(
    String s, {
    required bool attribute,
    int start = 0,
    int? end,
  }) {
    final stop = end ?? s.length;
    // Room for the worst case: every character becomes `&quot;`.
    if (_len + (stop - start) * 6 > _buf.length) _grow((stop - start) * 6);
    final buf = _buf;
    var len = _len;
    for (var i = start; i < stop; i++) {
      final c = s.codeUnitAt(i);
      // Every escaped character is below `?`.
      if (c > 0x3e) {
        if (c > 0xff) {
          // Outside Latin-1: drop what this call wrote, take the string path.
          final part = start == 0 && stop == s.length
              ? s
              : s.substring(start, stop);
          write(attribute ? _escapeAttr(part) : _escapeText(part));
          return false;
        }
        buf[len++] = c;
        continue;
      }
      switch (c) {
        case 0x26: // &
          len = _putAscii(buf, len, '&amp;');
        case 0x3c: // <
          len = _putAscii(buf, len, '&lt;');
        case 0x3e: // >
          len = _putAscii(buf, len, '&gt;');
        case 0x22 when attribute: // "
          len = _putAscii(buf, len, '&quot;');
        case 0x0a when attribute: // \n
          buf[len++] = _space;
        default:
          buf[len++] = c;
      }
    }
    _len = len;
    return true;
  }

  /// Appends the escaped attribute value of [family]. A scene usually
  /// uses one font family for every text, so its escaped bytes are kept and
  /// copied for the next text with the same family.
  void writeFontFamily(String family) {
    if (!identical(family, _family)) {
      final mark = _len;
      if (!writeEscaped(family, attribute: true)) {
        // Added as a separate part (outside Latin-1): nothing to keep.
        _family = null;
        return;
      }
      _family = family;
      _familyBytes = Uint8List.sublistView(_buf, mark, _len).sublist(0);
      return;
    }
    final bytes = _familyBytes;
    final n = bytes.length;
    if (_len + n > _buf.length) _grow(n);
    _buf.setRange(_len, _len + n, bytes);
    _len += n;
  }

  String? _family;
  Uint8List _familyBytes = Uint8List(0);

  /// Puts the ASCII string [s] into [buf] at [at] and returns the end.
  static int _putAscii(Uint8List buf, int at, String s) {
    for (var i = 0; i < s.length; i++) {
      buf[at++] = s.codeUnitAt(i);
    }
    return at;
  }

  /// Appends `#rrggbb` (lowercase) for the ARGB [value], ignoring alpha.
  void writeColor(int value) {
    if (_len + 7 > _buf.length) _grow(7);
    final buf = _buf;
    var len = _len;
    buf[len++] = 0x23; // #
    for (var shift = 20; shift >= 0; shift -= 4) {
      final d = (value >> shift) & 0xf;
      buf[len++] = d < 10 ? 0x30 + d : 0x57 + d; // 0-9, a-f
    }
    _len = len;
  }

  /// Appends one Latin-1 character code.
  @pragma('vm:prefer-inline')
  void writeCharCode(int c) {
    if (_len == _buf.length) _grow(1);
    _buf[_len++] = c;
  }

  /// Appends [v] in the [_num] format. This runs for every coordinate in
  /// the scene, so the common case writes the digits of the integer
  /// hundredths directly and only falls back to the string path near a
  /// rounding tie (where `v * 100` may round differently from the exact
  /// decimal value), for `-0`, and for huge or non-finite values.
  void writeNum(double v) {
    // Room for a sign, 19 digits, a dot and two decimals.
    if (_len + 24 > _buf.length) _grow(24);
    if (v == v.roundToDouble()) {
      final n = v.round();
      if (n >= 0 && n < _maxDigitsValue) {
        _putDigits(n);
      } else if (n < 0 && n > -_maxDigitsValue) {
        _buf[_len++] = 0x2d; // -
        _putDigits(-n);
      } else {
        write('$n');
      }
      return;
    }
    final scaled = v * 100;
    if (scaled < 1e15 && scaled > -1e15) {
      final r = scaled.round();
      final diff = scaled - r;
      final tie =
          diff > 0.499999 && diff < 0.500001 ||
          diff < -0.499999 && diff > -0.500001;
      if (r != 0 && !tie) {
        var a = r;
        if (r < 0) {
          _buf[_len++] = 0x2d; // -
          a = -r;
        }
        final whole = a ~/ 100;
        _putDigits(whole);
        final frac = a - whole * 100;
        if (frac != 0) {
          final tens = frac ~/ 10;
          final ones = frac - tens * 10;
          _buf[_len++] = 0x2e; // .
          _buf[_len++] = 0x30 + tens;
          if (ones != 0) _buf[_len++] = 0x30 + ones;
        }
        return;
      }
    }
    write(_numSlow(v));
  }

  /// Puts the decimal digits of [n] (`0 <= n < 10^19`); the caller made
  /// room for them.
  void _putDigits(int n) {
    final buf = _buf;
    if (n < 10) {
      buf[_len++] = 0x30 + n;
      return;
    }
    var digits = n < 100
        ? 2
        : n < 1000
        ? 3
        : n < 10000
        ? 4
        : n < 100000
        ? 5
        : 6;
    for (var t = n ~/ 1000000; t > 0; t ~/= 10) {
      digits++;
    }
    final end = _len + digits;
    var i = end;
    do {
      final q = n ~/ 10;
      buf[--i] = 0x30 + n - q * 10;
      n = q;
    } while (n > 0);
    _len = end;
  }

  void _grow(int extra) {
    final next = Uint8List(math.max(_buf.length * 2, _len + extra));
    next.setRange(0, _len, _buf);
    _buf = next;
  }

  void _addPart(String s) {
    _flush();
    _parts!.add(s);
  }

  void _flush() {
    (_parts ??= []).add(String.fromCharCodes(_buf, 0, _len));
    _len = 0;
  }

  @override
  String toString() {
    if (_parts == null) return String.fromCharCodes(_buf, 0, _len);
    _flush();
    return _parts!.join();
  }
}

class _IdGen {
  int _n = 0;
  String next() => 'g${_n++}';
}

/// Writes [nodes] in order. The styled runs of one label line (consecutive
/// texts whose [SceneText.run] numbers them 0 to count - 1) become one
/// `<text>`, so the browser places the runs with its own glyph widths.
void _writeNodes(_SvgWriter b, List<SceneNode> nodes, _IdGen ids) {
  var i = 0;
  while (i < nodes.length) {
    final count = _runLineLength(nodes, i);
    if (count > 0) {
      _writeRunLine(b, nodes, i, count);
      i += count;
    } else {
      _writeNode(b, nodes[i], ids);
      i++;
    }
  }
}

/// Number of nodes from [start] that form one line of styled runs, or 0.
int _runLineLength(List<SceneNode> nodes, int start) {
  final first = nodes[start];
  if (first is! SceneText || first.rotation != 0) return 0;
  final run = first.run;
  if (run == null || run.index != 0 || start + run.count > nodes.length) {
    return 0;
  }
  for (var k = 1; k < run.count; k++) {
    final node = nodes[start + k];
    if (node is! SceneText || node.run?.index != k) return 0;
  }
  return run.count;
}

/// Writes runs `nodes[start, start + count)` as one `<text>` with a
/// `<tspan>` per run. Spaces between runs are kept (`xml:space`), because
/// the layout measured them.
void _writeRunLine(_SvgWriter b, List<SceneNode> nodes, int start, int count) {
  final first = nodes[start] as SceneText;
  final run = first.run!;
  final left = first.bounds.left + run.lineLeft;
  final (anchor, x) = switch (run.lineAlign) {
    TextAlignH.left => ('start', left),
    TextAlignH.center => ('middle', left + run.lineWidth / 2),
    TextAlignH.right => ('end', left + run.lineWidth),
  };
  b
    ..write('<text xml:space="preserve" text-anchor="')
    ..write(anchor)
    ..write('" x="');
  _writeNum(b, x);
  b.write('" y="');
  _writeNum(b, first.bounds.top + first.bounds.height * 0.78);
  b
    ..write('" font-family="')
    ..writeFontFamily(_svgFontFamily(first.style))
    ..write('" font-size="');
  _writeNum(b, first.style.fontSize);
  b.write('" fill="');
  _writeColor(b, first.color);
  b.write('">');
  for (var k = 0; k < count; k++) {
    final text = nodes[start + k] as SceneText;
    final style = text.style;
    b.write('<tspan');
    if (style.fontWeight != 400) b.write(' font-weight="${style.fontWeight}"');
    if (style.italic) b.write(' font-style="italic"');
    b
      ..write('>')
      ..writeEscaped(text.run!.text, attribute: false)
      ..write('</tspan>');
  }
  b.write('</text>');
}

void _writeNode(_SvgWriter b, SceneNode node, _IdGen ids) {
  switch (node) {
    case SceneGroup(
      :final id,
      :final semanticLabel,
      :final link,
      :final tooltip,
      :final children,
    ):
      // A linked group becomes an SVG hyperlink.
      if (link != null) {
        b.write('<a href="${_escapeAttr(link)}" target="_blank">');
      }
      b.write('<g');
      if (id != null) {
        b.write(' id="');
        b.writeEscaped(id, attribute: true);
        b.writeCharCode(_quote);
      }
      if (semanticLabel != null) {
        b.write(' aria-label="');
        b.writeEscaped(semanticLabel, attribute: true);
        b.writeCharCode(_quote);
      }
      if (link != null) b.write(' style="cursor:pointer"');
      b.write('>');
      if (tooltip != null) {
        b.write('<title>${_escapeText(tooltip)}</title>');
      }
      _writeNodes(b, children, ids);
      b.write('</g>');
      if (link != null) b.write('</a>');

    case SceneShape(
      :final geometry,
      :final fill,
      :final stroke,
      :final blendMode,
    ):
      // Gradients are defined just before the shape that paints with them.
      final fillGradient = fill?.gradient;
      final fillId = fillGradient == null
          ? null
          : _writeGradient(b, fillGradient, ids);
      final strokeGradient = stroke?.gradient;
      final strokeId = strokeGradient == null
          ? null
          : _writeGradient(b, strokeGradient, ids);
      switch (geometry) {
        case RectGeometry(:final rect, :final rx):
          b.write('<rect x="');
          _writeNum(b, rect.left);
          b.write('" y="');
          _writeNum(b, rect.top);
          b.write('" width="');
          _writeNum(b, rect.width);
          b.write('" height="');
          _writeNum(b, rect.height);
          b.writeCharCode(_quote);
          if (rx > 0) {
            b.write(' rx="');
            _writeNum(b, rx);
            b.writeCharCode(_quote);
          }
        case CircleGeometry(:final center, :final radius):
          b.write('<circle cx="');
          _writeNum(b, center.x);
          b.write('" cy="');
          _writeNum(b, center.y);
          b.write('" r="');
          _writeNum(b, radius);
          b.writeCharCode(_quote);
        case EllipseGeometry(:final center, :final rx, :final ry):
          b.write('<ellipse cx="');
          _writeNum(b, center.x);
          b.write('" cy="');
          _writeNum(b, center.y);
          b.write('" rx="');
          _writeNum(b, rx);
          b.write('" ry="');
          _writeNum(b, ry);
          b.writeCharCode(_quote);
        case PolygonGeometry(:final points):
          b.write('<polygon points="');
          for (var i = 0; i < points.length; i++) {
            if (i > 0) b.writeCharCode(_space);
            _writeNum(b, points[i].x);
            b.writeCharCode(_comma);
            _writeNum(b, points[i].y);
          }
          b.writeCharCode(_quote);
        case PathGeometry(:final commands):
          b.write('<path d="');
          for (final c in commands) {
            switch (c) {
              case MoveTo(:final p):
                b.writeCharCode(0x4d); // M
                _writePoint(b, p);
              case LineTo(:final p):
                b.writeCharCode(0x4c); // L
                _writePoint(b, p);
              case QuadTo(:final c, :final p):
                b.writeCharCode(0x51); // Q
                _writePoint(b, c);
                b.writeCharCode(_space);
                _writePoint(b, p);
              case CubicTo(:final c1, :final c2, :final p):
                b.writeCharCode(0x43); // C
                _writePoint(b, c1);
                b.writeCharCode(_space);
                _writePoint(b, c2);
                b.writeCharCode(_space);
                _writePoint(b, p);
              case ClosePath():
                b.writeCharCode(0x5a); // Z
            }
          }
          b.writeCharCode(_quote);
      }
      _writePaint(b, fill, stroke, fillId, strokeId, blendMode);
      b.write('/>');

    case SceneText(
      :final text,
      :final bounds,
      :final style,
      :final color,
      :final align,
      :final rotation,
      :final underline,
    ):
      // Lines are written as ranges of [text], without splitting it.
      var lineCount = 1;
      for (var i = 0; i < text.length; i++) {
        if (text.codeUnitAt(i) == 0x0a) lineCount++;
      }
      final lineHeight = bounds.height / lineCount;
      final (anchor, x) = switch (align) {
        TextAlignH.left => ('start', bounds.left),
        TextAlignH.center => ('middle', bounds.center.x),
        TextAlignH.right => ('end', bounds.right),
      };
      if (rotation != 0) {
        b.write('<g transform="rotate(');
        _writeNum(b, rotation);
        b.writeCharCode(_space);
        _writePoint(b, bounds.center);
        b.write(')">');
      }
      b
        ..write('<text text-anchor="')
        ..write(anchor)
        ..write('" font-family="')
        ..writeFontFamily(_svgFontFamily(style))
        ..write('" font-size="');
      _writeNum(b, style.fontSize);
      b.writeCharCode(_quote);
      if (style.fontWeight != 400) {
        b.write(' font-weight="${style.fontWeight}"');
      }
      if (style.italic) b.write(' font-style="italic"');
      if (underline) b.write(' text-decoration="underline"');
      b.write(' fill="');
      _writeColor(b, color);
      b.write('">');
      var lineStart = 0;
      for (var i = 0; i < lineCount; i++) {
        var lineEnd = lineStart;
        while (lineEnd < text.length && text.codeUnitAt(lineEnd) != 0x0a) {
          lineEnd++;
        }
        final y = bounds.top + lineHeight * i + lineHeight * 0.78;
        b.write('<tspan x="');
        _writeNum(b, x);
        b.write('" y="');
        _writeNum(b, y);
        b
          ..write('">')
          ..writeEscaped(text, attribute: false, start: lineStart, end: lineEnd)
          ..write('</tspan>');
        lineStart = lineEnd + 1;
      }
      b.write('</text>');
      if (rotation != 0) b.write('</g>');
  }
}

const _quote = 0x22;
const _space = 0x20;
const _comma = 0x2c;

/// Writes a `<linearGradient>` definition and returns its id.
String _writeGradient(_SvgWriter b, SceneGradient gradient, _IdGen ids) {
  final gid = ids.next();
  b
    ..write('<linearGradient id="')
    ..write(gid)
    ..write('" gradientUnits="userSpaceOnUse" x1="');
  _writeNum(b, gradient.from.x);
  b.write('" y1="');
  _writeNum(b, gradient.from.y);
  b.write('" x2="');
  _writeNum(b, gradient.to.x);
  b.write('" y2="');
  _writeNum(b, gradient.to.y);
  b.write('">');
  final colors = gradient.colors;
  for (var i = 0; i < colors.length; i++) {
    final c = colors[i];
    final off = colors.length == 1 ? 0.0 : i / (colors.length - 1);
    b.write('<stop offset="');
    _writeNum(b, off);
    b.write('" stop-color="');
    _writeColor(b, c);
    b.writeCharCode(_quote);
    if (c.alpha < 255) {
      b.write(' stop-opacity="');
      _writeNum(b, c.alpha / 255);
      b.writeCharCode(_quote);
    }
    b.write('/>');
  }
  b.write('</linearGradient>');
  return gid;
}

/// Writes the fill, stroke and blend attributes of a shape.
void _writePaint(
  _SvgWriter b,
  Fill? fill,
  Stroke? stroke,
  String? fillId,
  String? strokeId,
  SceneBlendMode blendMode,
) {
  if (fillId != null) {
    b.write(' fill="url(#$fillId)"');
  } else if (fill == null) {
    b.write(' fill="none"');
  } else {
    b.write(' fill="');
    _writeColor(b, fill.color);
    b.writeCharCode(_quote);
    if (fill.color.alpha < 255 && fill.color.alpha > 0) {
      b.write(' fill-opacity="');
      _writeNum(b, fill.color.alpha / 255);
      b.writeCharCode(_quote);
    }
  }
  if (stroke != null) {
    if (strokeId != null) {
      b.write(' stroke="url(#$strokeId)"');
    } else {
      b.write(' stroke="');
      _writeColor(b, stroke.color);
      b.writeCharCode(_quote);
      if (stroke.color.alpha < 255 && stroke.color.alpha > 0) {
        b.write(' stroke-opacity="');
        _writeNum(b, stroke.color.alpha / 255);
        b.writeCharCode(_quote);
      }
    }
    b.write(' stroke-width="');
    _writeNum(b, stroke.width);
    b.writeCharCode(_quote);
    final dash = stroke.dash;
    if (dash != null && dash.isNotEmpty) {
      b.write(' stroke-dasharray="');
      for (var i = 0; i < dash.length; i++) {
        if (i > 0) b.writeCharCode(_comma);
        _writeNum(b, dash[i]);
      }
      b.writeCharCode(_quote);
    }
  }
  if (blendMode == SceneBlendMode.multiply) {
    b.write(' style="mix-blend-mode:multiply"');
  }
}

/// Writes `x y` of [p].
void _writePoint(_SvgWriter b, Point p) {
  _writeNum(b, p.x);
  b.writeCharCode(_space);
  _writeNum(b, p.y);
}

String _svgFontFamily(TextStyleSpec style) => style.fontFamily;

/// True if any text node uses a KaTeX math font (so we embed the @font-face).
bool _usesKatex(List<SceneNode> nodes) {
  for (var i = 0; i < nodes.length; i++) {
    switch (nodes[i]) {
      case SceneGroup(:final children):
        if (_usesKatex(children)) return true;
      case SceneText(:final style):
        final family = style.fontFamily;
        // `K` rejects the usual family without a prefix compare.
        if (family.isNotEmpty &&
            family.codeUnitAt(0) == 0x4b &&
            family.startsWith('KaTeX_')) {
          return true;
        }
      case SceneShape():
        break;
    }
  }
  return false;
}

/// Formats [v] like `toStringAsFixed(2)` with trailing zeros (and a trailing
/// dot) removed.
String _num(double v) {
  final b = _SvgWriter(16);
  _writeNum(b, v);
  return b.toString();
}

/// Writes [v] in the [_num] format.
void _writeNum(_SvgWriter b, double v) => b.writeNum(v);

const _maxDigitsValue = 1000000000000000000;

/// `toStringAsFixed(2)` with trailing zeros and then a trailing dot removed.
String _numSlow(double v) {
  final s = v.toStringAsFixed(2);
  var end = s.length;
  while (end > 0 && s.codeUnitAt(end - 1) == 0x30) {
    end--;
  }
  if (end > 0 && s.codeUnitAt(end - 1) == 0x2e) end--;
  return end == s.length ? s : s.substring(0, end);
}

String _color(Color c) {
  final b = _SvgWriter(16);
  _writeColor(b, c);
  return b.toString();
}

/// Writes `#rrggbb` (lowercase) for [c], ignoring alpha.
void _writeColor(_SvgWriter b, Color c) => b.writeColor(c.value);

String _escapeText(String s) => !_needsEscape(s, false)
    ? s
    : s
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');

String _escapeAttr(String s) {
  if (!_needsEscape(s, true)) return s;
  // Font family lists usually hold quoted names: keep their escaped form.
  final cached = _escapedAttrs[s];
  if (cached != null) return cached;
  if (_escapedAttrs.length >= 64) _escapedAttrs.clear();
  return _escapedAttrs[s] = _escapeText(
    s,
  ).replaceAll('"', '&quot;').replaceAll('\n', ' ');
}

final _escapedAttrs = <String, String>{};

/// True if [s] has a character that [_escapeText] (or, for an [attribute],
/// [_escapeAttr]) replaces. Most labels have none.
bool _needsEscape(String s, bool attribute) {
  for (var i = 0; i < s.length; i++) {
    switch (s.codeUnitAt(i)) {
      case 0x26 || 0x3c || 0x3e: // & < >
        return true;
      case 0x22 || 0x0a when attribute: // " \n
        return true;
    }
  }
  return false;
}
