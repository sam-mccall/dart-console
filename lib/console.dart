// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#library("console");
#import("readline.dart", prefix: 'readline');
#import("sandbox.dart");
#import("fragment_parser.dart");

class Console {
  var stdin;
  var sandbox;
  Console() : 
      stdin = new readline.Input(), 
      sandbox = new Sandbox();

  run() {
    stdin.loop(">> ", (line) {
      try {
        var input = new FragmentParser().append(line);
        while (true) switch (input.state) {
          case FragmentParser.INCOMPLETE:
            var line = stdin.readline("${input.context}> ");
            if (line == null) return true;
            input.append("$line\n");
            break;
          case FragmentParser.DECLARATION: return sandbox.declare(input.toString());
          case FragmentParser.EXPRESSION: return print(sandbox.eval(input.toString()));
          case FragmentParser.STATEMENT: return sandbox.execute(input.toString());
        }
      } catch (Object e) {
        print((e is Exception) ? e : "Exception: $e");
      }
    });
  }
}
