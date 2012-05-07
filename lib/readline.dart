// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#library("readline");

#import("dart-ext:dart_readline");

class Input {
  History history;
  String prompt;

  Input([prompt]) {
    history = new History();
    this.prompt = (prompt == null) ? "> " : prompt.toString();
  }

  readline([prompt]) {
    prompt = (prompt == null) ? this.prompt : prompt.toString();
    var result = _readline(prompt);
    if (history.auto && result != null && result != "") {
      history.add(result);
    }
    return result;
  }

  loop(prompt, callback(line)) {
    while(true) {
      var line = readline(prompt);
      if (line == null) break;
      if (line.isEmpty()) continue;
      try {
        if (callback(line)) break;
      } catch (Exception e) {
        print(e);        
      }
    }
  }
}

class History {
  bool auto;

  History() : auto = true;
  add(text) => _history_add(text);
}

_newException(x) => new Exception(x);

_readline(prompt) native "Readline";
_history_add(text) native "History_Add";