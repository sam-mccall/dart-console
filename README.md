dart-console: An interactive console for Dart
=============================================

# Prerequisites
  * Dart source tree (strictly, you just need runtime/include/dart_api.h)
  * Dart SDK, if you want to generate documentation
  * libreadline-dev
  * Linux or Mac, g++ toolchain. (Windows is too hard, for now...)

Either edit build.sh to point to the source tree and SDK, or set the
environment variables DART_SOURCES and DART_SDK.

# Building and running
    ./build.sh
    bin/console

# Limitations and workarounds

## You can't "overwrite" a declared name.

    >> foo() => 1;
    >> foo() => 2;
    Exception: 'console_declaration_3': Error: line 1 pos 1: 'foo' is already defined

Workaround: use variables instead of declarations

    >> foo = () => 1;
    >> foo = () => 2;
    >> foo()
    2

## Global variables not detected within declarations

    >> bar() { x = 2; }
    >> bar();
    Exception: 'console_declaration_4': Error: line 1 pos 9: identifier 'x' is not declared in this scope

Workaround: initialize them in a statement beforehand

    >> x = null;
    >> bar() { x = 2; }
    >> bar();
    >> x
    2

Workaround: use the VARIABLES map
    >> bar() { VARIABLES['x'] = 2; }
    >> bar();
    >> x
    2

## Messages and behaviour are confusing when the console guesses your intent wrong

    >> x() => 2 + 2 // missing semicolon
    Closure
    >> x
    NoSuchMethodException : method not found: 'get:x'

Workaround: understand the types of input the console accepts
  * Declarations: inserted at the top level.
    * Input ending in }
    * Lambda declarations like `baz() => 42;`
  * Statements: wrapped in a method like `_execute() {$code}` and called
    * Input ending in ;
  * Expressions: wrapped in a method like `_execute() {return ($code);}` and called
    * Everything else

# Documentation
Not yet, poke around the code...

# Tests
There are tests for the parsing and sandbox libraries, under test/. To run them:

    ./build.sh test

# Legal stuff
Copyright 2012 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
