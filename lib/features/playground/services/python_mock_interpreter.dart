/// A lightweight, offline, sandboxed interpreter for a *subset* of Python.
///
/// WHY THIS EXISTS:
/// The app is offline-first and runs entirely on-device (no backend server).
/// Running *real* CPython on a phone requires either (a) a bundled native
/// Python runtime per platform, or (b) a remote execution sandbox — both are
/// substantial infrastructure projects on their own. For the lesson
/// challenges and Playground exercises taught in this app (variables,
/// print, arithmetic, conditions, loops, functions, lists), this
/// interpreter supports the real syntax students type and gives real,
/// correct output — entirely offline and instantly.
///
/// ROADMAP NOTE: A future version can swap this for an embedded runtime
/// (e.g. a WASM-compiled CPython such as Pyodide loaded in a hidden WebView,
/// or a server-side sandboxed execution API) for full-language support,
/// without changing any calling code — see PythonExecutionEngine below.
library python_mock_interpreter;

abstract class PythonExecutionEngine {
  static String run(String code) => PythonMockInterpreter.run(code);
}

class _PyRuntimeError implements Exception {
  final String message;
  _PyRuntimeError(this.message);
}

class PythonMockInterpreter {
  static String run(String code) {
    final buffer = StringBuffer();
    final env = <String, dynamic>{};
    try {
      final lines = code.replaceAll('\r\n', '\n').split('\n');
      _execBlock(_toLogicalLines(lines), 0, env, buffer);
    } on _PyRuntimeError catch (e) {
      buffer.writeln('Хатогӣ: ${e.message}');
    } catch (e) {
      buffer.writeln('Хатогӣ: коди шумо иҷро нашуд ($e)');
    }
    return buffer.toString().trimRight();
  }

  // --- Line model -----------------------------------------------------

  static List<_Line> _toLogicalLines(List<String> raw) {
    final result = <_Line>[];
    for (final r in raw) {
      if (r.trim().isEmpty || r.trim().startsWith('#')) continue;
      final indent = r.length - r.trimLeft().length;
      result.add(_Line(indent, r.trim()));
    }
    return result;
  }

  /// Executes statements at [minIndent] starting at [start], returns the
  /// index of the next unconsumed line.
  static int _execBlock(
    List<_Line> lines,
    int start,
    Map<String, dynamic> env,
    StringBuffer out, {
    int? blockIndent,
  }) {
    int i = start;
    if (lines.isEmpty) return i;
    final indent = blockIndent ?? lines[start].indent;

    while (i < lines.length) {
      final line = lines[i];
      if (line.indent < indent) break;
      if (line.indent > indent) {
        throw _PyRuntimeError('дукогазии номунтазам (indentation)');
      }

      final text = line.text;

      if (text.startsWith('if ') && text.endsWith(':')) {
        i = _execIf(lines, i, env, out, indent);
        continue;
      }
      if (text.startsWith('for ') && text.endsWith(':')) {
        i = _execFor(lines, i, env, out, indent);
        continue;
      }
      if (text.startsWith('while ') && text.endsWith(':')) {
        i = _execWhile(lines, i, env, out, indent);
        continue;
      }
      if (text.startsWith('def ') && text.endsWith(':')) {
        i = _defineFunc(lines, i, env, indent);
        continue;
      }
      if (text == 'pass') {
        i++;
        continue;
      }
      if (text.startsWith('return ')) {
        throw _ReturnSignal(_eval(text.substring(7), env));
      }

      _execStatement(text, env, out);
      i++;
    }
    return i;
  }

  static void _execStatement(String text, Map<String, dynamic> env, StringBuffer out) {
    if (text.startsWith('print(') && text.endsWith(')')) {
      final argsStr = text.substring(6, text.length - 1);
      final args = _splitArgs(argsStr);
      final values = args.map((a) => _stringify(_eval(a, env))).join(' ');
      out.writeln(values);
      return;
    }

    // Compound assignment: x += 1, x -= 1 etc.
    final compoundMatch = RegExp(r'^([a-zA-Z_]\w*)\s*(\+=|-=|\*=|/=)\s*(.+)$').firstMatch(text);
    if (compoundMatch != null) {
      final name = compoundMatch.group(1)!;
      final op = compoundMatch.group(2)!;
      final rhs = _eval(compoundMatch.group(3)!, env);
      final current = env[name];
      switch (op) {
        case '+=':
          env[name] = _add(current, rhs);
          break;
        case '-=':
          env[name] = (current as num) - (rhs as num);
          break;
        case '*=':
          env[name] = (current as num) * (rhs as num);
          break;
        case '/=':
          env[name] = (current as num) / (rhs as num);
          break;
      }
      return;
    }

    // method call like list.append(x)
    final methodMatch = RegExp(r'^([a-zA-Z_]\w*)\.(\w+)\((.*)\)$').firstMatch(text);
    if (methodMatch != null) {
      final target = env[methodMatch.group(1)!];
      final method = methodMatch.group(2)!;
      final argsStr = methodMatch.group(3)!;
      if (target is List && method == 'append') {
        target.add(_eval(argsStr, env));
        return;
      }
      throw _PyRuntimeError('методи дастнорас: $method');
    }

    // Plain assignment: name = expr
    final assignMatch = RegExp(r'^([a-zA-Z_]\w*)\s*=\s*(.+)$').firstMatch(text);
    if (assignMatch != null) {
      env[assignMatch.group(1)!] = _eval(assignMatch.group(2)!, env);
      return;
    }

    // Bare expression (e.g. a function call whose value is discarded)
    _eval(text, env);
  }

  static int _execIf(
    List<_Line> lines,
    int start,
    Map<String, dynamic> env,
    StringBuffer out,
    int indent,
  ) {
    int i = start;
    bool branchTaken = false;

    while (i < lines.length && lines[i].indent == indent) {
      final header = lines[i].text;
      final isIf = header.startsWith('if ');
      final isElif = header.startsWith('elif ');
      final isElse = header == 'else:';

      if (!isIf && !isElif && !isElse) break;

      final bodyStart = i + 1;
      final childIndent = (bodyStart < lines.length) ? lines[bodyStart].indent : indent + 4;

      bool condition;
      if (isElse) {
        condition = !branchTaken;
      } else {
        final condStr = header.substring(header.indexOf(' ') + 1, header.length - 1);
        condition = !branchTaken && _truthy(_eval(condStr, env));
      }

      int nextIndex;
      if (condition) {
        nextIndex = _execBlock(lines, bodyStart, env, out, blockIndent: childIndent);
        branchTaken = true;
      } else {
        nextIndex = _skipBlock(lines, bodyStart, childIndent);
      }
      i = nextIndex;
    }
    return i;
  }

  static int _execFor(
    List<_Line> lines,
    int start,
    Map<String, dynamic> env,
    StringBuffer out,
    int indent,
  ) {
    final header = lines[start].text;
    final match = RegExp(r'^for\s+(\w+)\s+in\s+(.+):$').firstMatch(header);
    if (match == null) throw _PyRuntimeError('сохти нодурусти for');
    final varName = match.group(1)!;
    final iterableExpr = match.group(2)!;

    final bodyStart = start + 1;
    final childIndent = (bodyStart < lines.length) ? lines[bodyStart].indent : indent + 4;
    final iterable = _evalIterable(iterableExpr, env);

    int endIndex = _skipBlock(lines, bodyStart, childIndent, dryRun: true);

    for (final value in iterable) {
      env[varName] = value;
      _execBlock(lines, bodyStart, env, out, blockIndent: childIndent);
    }
    return endIndex;
  }

  static int _execWhile(
    List<_Line> lines,
    int start,
    Map<String, dynamic> env,
    StringBuffer out,
    int indent,
  ) {
    final header = lines[start].text;
    final condStr = header.substring(6, header.length - 1);
    final bodyStart = start + 1;
    final childIndent = (bodyStart < lines.length) ? lines[bodyStart].indent : indent + 4;

    int endIndex = _skipBlock(lines, bodyStart, childIndent, dryRun: true);

    int guard = 0;
    while (_truthy(_eval(condStr, env))) {
      _execBlock(lines, bodyStart, env, out, blockIndent: childIndent);
      guard++;
      if (guard > 10000) throw _PyRuntimeError('давра хеле дароз шуд (беохир?)');
    }
    return endIndex;
  }

  static int _defineFunc(
    List<_Line> lines,
    int start,
    Map<String, dynamic> env,
    int indent,
  ) {
    final header = lines[start].text;
    final match = RegExp(r'^def\s+(\w+)\((.*)\):$').firstMatch(header);
    if (match == null) throw _PyRuntimeError('сохти нодурусти def');
    final name = match.group(1)!;
    final params = match.group(2)!.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

    final bodyStart = start + 1;
    final childIndent = (bodyStart < lines.length) ? lines[bodyStart].indent : indent + 4;
    final endIndex = _skipBlock(lines, bodyStart, childIndent, dryRun: true);
    final bodyLines = lines.sublist(bodyStart, endIndex);

    env[name] = _PyFunction(params, bodyLines, childIndent);
    return endIndex;
  }

  /// Skips (or, if [dryRun] is false, this isn't used) a nested block and
  /// returns the index right after it ends.
  static int _skipBlock(List<_Line> lines, int start, int indent, {bool dryRun = false}) {
    int i = start;
    while (i < lines.length && lines[i].indent >= indent) {
      i++;
    }
    return i;
  }

  // --- Expression evaluation -------------------------------------------

  static List<String> _splitArgs(String argsStr) {
    final args = <String>[];
    int depth = 0;
    bool inStr = false;
    String quoteChar = '';
    final buf = StringBuffer();
    for (int i = 0; i < argsStr.length; i++) {
      final c = argsStr[i];
      if (inStr) {
        buf.write(c);
        if (c == quoteChar) inStr = false;
        continue;
      }
      if (c == '"' || c == "'") {
        inStr = true;
        quoteChar = c;
        buf.write(c);
        continue;
      }
      if (c == '(' || c == '[') depth++;
      if (c == ')' || c == ']') depth--;
      if (c == ',' && depth == 0) {
        args.add(buf.toString().trim());
        buf.clear();
        continue;
      }
      buf.write(c);
    }
    if (buf.toString().trim().isNotEmpty) args.add(buf.toString().trim());
    return args;
  }

  static Iterable<dynamic> _evalIterable(String expr, Map<String, dynamic> env) {
    final rangeMatch = RegExp(r'^range\((.*)\)$').firstMatch(expr.trim());
    if (rangeMatch != null) {
      final parts = _splitArgs(rangeMatch.group(1)!).map((p) => (_eval(p, env) as num).toInt()).toList();
      if (parts.length == 1) return List.generate(parts[0], (i) => i);
      if (parts.length == 2) return [for (int i = parts[0]; i < parts[1]; i++) i];
      if (parts.length == 3) {
        final result = <int>[];
        for (int i = parts[0]; parts[2] > 0 ? i < parts[1] : i > parts[1]; i += parts[2]) {
          result.add(i);
        }
        return result;
      }
    }
    final value = _eval(expr, env);
    if (value is List) return value;
    if (value is String) return value.split('');
    throw _PyRuntimeError('чизе, ки такроршаванда нест: $expr');
  }

  static dynamic _eval(String expr, Map<String, dynamic> env) {
    return _ExprParser(expr.trim(), env).parseExpression();
  }

  static bool _truthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }

  static dynamic _add(dynamic a, dynamic b) {
    if (a is String || b is String) return _stringify(a) + _stringify(b);
    if (a is num && b is num) return a + b;
    if (a is List && b is List) return [...a, ...b];
    throw _PyRuntimeError('намудҳои номувофиқ барои +');
  }

  static String _stringify(dynamic value) {
    if (value is bool) return value ? 'True' : 'False';
    if (value is double && value == value.roundToDouble()) {
      return value.toStringAsFixed(1);
    }
    if (value is List) return '[${value.map(_stringify).join(', ')}]';
    return value.toString();
  }
}

class _Line {
  final int indent;
  final String text;
  _Line(this.indent, this.text);
}

class _ReturnSignal implements Exception {
  final dynamic value;
  _ReturnSignal(this.value);
}

class _PyFunction {
  final List<String> params;
  final List<_Line> body;
  final int bodyIndent;
  _PyFunction(this.params, this.body, this.bodyIndent);
}

/// Minimal recursive-descent expression parser supporting:
/// literals (numbers, strings, True/False/None), variables, +,-,*,/,//,%,**,
/// comparisons, parentheses, list literals, indexing, and function calls
/// (including user-defined functions and len()).
class _ExprParser {
  final String src;
  final Map<String, dynamic> env;
  int pos = 0;

  _ExprParser(this.src, this.env);

  dynamic parseExpression() => _parseComparison();

  void _skipWs() {
    while (pos < src.length && src[pos] == ' ') pos++;
  }

  bool _match(String token) {
    _skipWs();
    if (src.startsWith(token, pos)) {
      pos += token.length;
      return true;
    }
    return false;
  }

  dynamic _parseComparison() {
    var left = _parseAdditive();
    _skipWs();
    for (final op in ['==', '!=', '>=', '<=', '>', '<']) {
      if (src.startsWith(op, pos)) {
        pos += op.length;
        final right = _parseAdditive();
        left = _compare(left, op, right);
      }
    }
    return left;
  }

  dynamic _compare(dynamic l, String op, dynamic r) {
    switch (op) {
      case '==':
        return l == r;
      case '!=':
        return l != r;
      case '>=':
        return (l as Comparable).compareTo(r) >= 0;
      case '<=':
        return (l as Comparable).compareTo(r) <= 0;
      case '>':
        return (l as Comparable).compareTo(r) > 0;
      case '<':
        return (l as Comparable).compareTo(r) < 0;
    }
    throw _PyRuntimeError('оператори номаълум $op');
  }

  dynamic _parseAdditive() {
    var value = _parseTerm();
    while (true) {
      _skipWs();
      if (pos < src.length && src[pos] == '+') {
        pos++;
        value = PythonMockInterpreter._add(value, _parseTerm());
      } else if (pos < src.length && src[pos] == '-' && !src.startsWith('->', pos)) {
        pos++;
        value = (value as num) - (_parseTerm() as num);
      } else {
        break;
      }
    }
    return value;
  }

  dynamic _parseTerm() {
    var value = _parsePower();
    while (true) {
      _skipWs();
      if (src.startsWith('//', pos)) {
        pos += 2;
        value = ((value as num) / (_parsePower() as num)).floor();
      } else if (pos < src.length && src[pos] == '*' && !src.startsWith('**', pos)) {
        pos++;
        value = (value as num) * (_parsePower() as num);
      } else if (pos < src.length && src[pos] == '/') {
        pos++;
        value = (value as num) / (_parsePower() as num);
      } else if (pos < src.length && src[pos] == '%') {
        pos++;
        value = (value as num) % (_parsePower() as num);
      } else {
        break;
      }
    }
    return value;
  }

  dynamic _parsePower() {
    var value = _parseUnary();
    _skipWs();
    if (src.startsWith('**', pos)) {
      pos += 2;
      final exp = _parsePower();
      value = (value as num).toDouble();
      double result = 1;
      for (int i = 0; i < (exp as num); i++) {
        result *= value;
      }
      return (result == result.roundToDouble()) ? result.toInt() : result;
    }
    return value;
  }

  dynamic _parseUnary() {
    _skipWs();
    if (pos < src.length && src[pos] == '-') {
      pos++;
      return -(_parseUnary() as num);
    }
    if (_match('not ')) {
      return !PythonMockInterpreter._truthy(_parseUnary());
    }
    return _parsePostfix();
  }

  dynamic _parsePostfix() {
    var value = _parsePrimary();
    while (true) {
      _skipWs();
      if (pos < src.length && src[pos] == '[') {
        pos++;
        final indexExpr = _readUntilMatching(']');
        final index = (_ExprParser(indexExpr, env).parseExpression() as num).toInt();
        value = (value as List)[index < 0 ? value.length + index : index];
      } else {
        break;
      }
    }
    return value;
  }

  String _readUntilMatching(String closeChar) {
    int depth = 1;
    final start = pos;
    while (pos < src.length && depth > 0) {
      if (src[pos] == '[' || src[pos] == '(') depth++;
      if (src[pos] == ']' || src[pos] == ')') depth--;
      if (depth == 0) break;
      pos++;
    }
    final result = src.substring(start, pos);
    pos++; // consume closing char
    return result;
  }

  dynamic _parsePrimary() {
    _skipWs();
    if (pos >= src.length) throw _PyRuntimeError('ифодаи нопурра');

    // Parenthesized
    if (src[pos] == '(') {
      pos++;
      final inner = _readUntilMatching(')');
      return _ExprParser(inner, env).parseExpression();
    }

    // List literal
    if (src[pos] == '[') {
      pos++;
      final inner = _readUntilMatching(']');
      if (inner.trim().isEmpty) return <dynamic>[];
      return PythonMockInterpreter._splitArgs(inner)
          .map((e) => _ExprParser(e, env).parseExpression())
          .toList();
    }

    // String literal
    if (src[pos] == '"' || src[pos] == "'") {
      final quote = src[pos];
      pos++;
      final start = pos;
      while (pos < src.length && src[pos] != quote) {
        pos++;
      }
      final value = src.substring(start, pos);
      pos++; // consume closing quote
      return value;
    }

    // Number literal
    final numMatch = RegExp(r'^\d+(\.\d+)?').matchAsPrefix(src, pos);
    if (numMatch != null) {
      pos = numMatch.end;
      final text = numMatch.group(0)!;
      return text.contains('.') ? double.parse(text) : int.parse(text);
    }

    // Identifier / keyword / function call
    final idMatch = RegExp(r'^[a-zA-Z_]\w*').matchAsPrefix(src, pos);
    if (idMatch != null) {
      final name = idMatch.group(0)!;
      pos = idMatch.end;
      _skipWs();

      if (name == 'True') return true;
      if (name == 'False') return false;
      if (name == 'None') return null;

      if (pos < src.length && src[pos] == '(') {
        pos++;
        final argsStr = _readUntilMatching(')');
        final argExprs = PythonMockInterpreter._splitArgs(argsStr);
        final args = argExprs.map((a) => _ExprParser(a, env).parseExpression()).toList();
        return _callFunction(name, args);
      }

      if (!env.containsKey(name)) {
        throw _PyRuntimeError("тағйирёбандаи '$name' муайян нашудааст");
      }
      return env[name];
    }

    throw _PyRuntimeError('ифодаи фаҳмо нест: "${src.substring(pos)}"');
  }

  dynamic _callFunction(String name, List<dynamic> args) {
    switch (name) {
      case 'len':
        final a = args[0];
        if (a is List) return a.length;
        if (a is String) return a.length;
        throw _PyRuntimeError('len() барои ин намуд кор намекунад');
      case 'str':
        return PythonMockInterpreter._stringify(args[0]);
      case 'int':
        return args[0] is String ? int.parse(args[0] as String) : (args[0] as num).toInt();
      case 'float':
        return args[0] is String ? double.parse(args[0] as String) : (args[0] as num).toDouble();
      case 'abs':
        return (args[0] as num).abs();
      case 'max':
        return args.reduce((a, b) => (a as Comparable).compareTo(b) >= 0 ? a : b);
      case 'min':
        return args.reduce((a, b) => (a as Comparable).compareTo(b) <= 0 ? a : b);
      case 'sum':
        return (args[0] as List).fold<num>(0, (p, e) => p + (e as num));
    }

    final fn = env[name];
    if (fn is _PyFunction) {
      final localEnv = Map<String, dynamic>.from(env);
      for (int i = 0; i < fn.params.length; i++) {
        localEnv[fn.params[i]] = i < args.length ? args[i] : null;
      }
      final out = StringBuffer();
      try {
        PythonMockInterpreter._execBlock(fn.body, 0, localEnv, out, blockIndent: fn.bodyIndent);
      } on _ReturnSignal catch (r) {
        return r.value;
      }
      return null;
    }

    throw _PyRuntimeError("функсияи '$name' муайян нашудааст");
  }
}
