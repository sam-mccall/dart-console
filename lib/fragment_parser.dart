// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#library("parser");

class FragmentParser {
  static final INCOMPLETE = 0, STATEMENT = 1, DECLARATION = 2, EXPRESSION = 3;

	var _buffer;
	var _stack;
	FragmentParser() : _buffer = new StringBuffer(), _stack = [];
	get context =>  _stack.isEmpty ? null : _stack[_stack.length - 1];

	void append(text) {
		text.splitChars().forEach(_updateStack);
		_buffer.add(text);
    return this;
	}

  _updateStack(c) {
    var context = this.context;
    if (context == '\$') {
      _stack.removeLast();
      if (c == '{') return _stack.add(c);
      return;
    }
    if (context == '\\') return _stack.removeLast();
    var quote = (context == '"' || context == "'");
    if (context == "'" && c == "'") return _stack.removeLast();
    if (context == '"' && c == '"') return _stack.removeLast();
    if (context == '{' && c =='}') return _stack.removeLast();
    if (context == '(' && c ==')') return _stack.removeLast();
    if (context == '[' && c ==']') return _stack.removeLast();
    if (quote && c == '\$') return _stack.add(c);
    if (quote && c == '\\') return _stack.add('\\');
    if (!quote && ['[','{','(','"',"'"].indexOf(c) >= 0) return _stack.add(c);
  }

  get state {
    if (!_stack.isEmpty) return INCOMPLETE;
    var text = toString().trim();
    if (_isMapLiteral(text)) return EXPRESSION;
    if (text.endsWith('}')) return DECLARATION;
    if (_isLambdaDeclaration(text)) return DECLARATION;
    if (text.endsWith(';')) return STATEMENT;
    return EXPRESSION;
  }

  // Matches 'arrow' declarations like x() => 42;
  _isLambdaDeclaration(text) {
    if (!text.endsWith(';')) return false;
    // up to three identifiers: void set foo(
    var prelude = const RegExp(r"^\s*([a-zA-Z0-9_$]+\s*){1,3}").firstMatch(text);
    if (prelude == null) return false;
    var end = prelude.end;
    if (end < text.length && text[end] == "(") end = _findBalance(text, prelude.end) + 1;
    return text.substring(end).trim().startsWith("=>");
  }

  // Matches map literals like {"x": y}, with optional type parameters.
  _isMapLiteral(text) {
    if (!text.endsWith('}')) return false;
    if (text.startsWith('{')) return true;
    return const RegExp(r"^<\s*[a-zA-Z0-9_$]+\s*(,\s*[a-zA-Z0-9_$]+\s*)?>").hasMatch(text);
  }

  // Returns the index after the character matching the token at pos.
  // No error handling!
  static _findBalance(text, pos) {
    var chars = text.splitChars();
    var cmd = new FragmentParser();
    do cmd._updateStack(chars[pos++]); while (!cmd._stack.isEmpty);
    return pos;
  }

  toString() => _buffer.toString();
}
