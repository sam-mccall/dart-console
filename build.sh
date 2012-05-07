#!/bin/bash

#DART_SDK=$HOME/dart-sdk

if [ -z "$DART_SDK" ]; then
  DART_SDK="$HOME/dart-sdk"
fi

buildlib() {
  LIBNAME=$1
  SRCS="src/$LIBNAME.cc $2"
  COPTS="-O2 -DDART_SHARED_LIB -I$DART_SDK/include -rdynamic -fPIC -m32"
  if [ "${DEBUG+x}" = "x" ]; then COPTS="-DDEBUG $COPTS"; fi

  UNAME=`uname`
  if [[ "$UNAME" == "Darwin" ]]; then
    COPTS="$COPTS -dynamiclib -undefined suppress -flat_namespace"
    OUTNAME="lib$LIBNAME.dylib"
  else
    if [[ "$UNAME" != "Linux" ]]; then
      echo "Warning: Unrecognized OS $UNAME, this likely won't work"
    fi
    COPTS="$COPTS -shared"
    OUTNAME="lib$OUTNAME.so"
  fi
  echo g++ $COPTS $SRCS -o lib/$OUTNAME
  g++ $COPTS $SRCS -o lib/$OUTNAME
}

build() {
  buildlib "dart_sandbox" && \
  buildlib "dart_readline" "-lreadline"
}

doc() {
  $DART_SDK/bin/dart $DART_SDK/lib/dartdoc/dartdoc.dart --mode=static lib/console.dart
}

test() {
  build && \
  $DART_SDK/bin/dart test/test.dart
}

if [ -z "$1" ]; then
  build $@
else
  $@
fi
