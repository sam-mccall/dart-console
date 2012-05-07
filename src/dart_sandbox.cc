// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#include <string.h>
#include <stdio.h>
#include "dart_util.h"

Dart_Handle get_library(Dart_Handle libraryNumberHandle) {
  int64_t libraryNumber;
  CheckDartError(Dart_IntegerToInt64(libraryNumberHandle, &libraryNumber));
  return (Dart_Handle) libraryNumber;
}

/** Creates a new library from [source], returns an integer handle. */
DART_FUNCTION(NewLibrary) {
  DART_ARGS_2(url, source);
  Dart_Handle lib = Dart_NewPersistentHandle(CheckDartError(Dart_LoadLibrary(url, source, Dart_Null())));
  DART_RETURN(Dart_NewInteger((int64_t) lib));
}

/** Adds declarations from [text] to [library]. */
DART_FUNCTION(Declare) {
  DART_ARGS_3(library, url, text);
  Dart_Handle libraryHandle = get_library(library);
  CheckDartError(Dart_LoadSource(libraryHandle, url, text));
  DART_RETURN(Dart_Null());
}

/** Invokes the no-args function [funcName] within the context of [library], returns the result. */
DART_FUNCTION(Invoke) {
  DART_ARGS_2(library, funcName);
  Dart_Handle libraryHandle = get_library(library);
  DART_RETURN(CheckDartError(Dart_Invoke(libraryHandle, funcName, 0, NULL)));
}

/** Imports the library named [importName] into [library]. */
DART_FUNCTION(Import) {
  DART_ARGS_3(library, importName, loadingClosure);
  Dart_Handle libraryHandle = get_library(library);
  Dart_Handle importHandle = Dart_LookupLibrary(importName);
  if (Dart_IsError(importHandle)) {
    Dart_Handle source = CheckDartError(Dart_InvokeClosure(loadingClosure, 0, NULL));
    importHandle = CheckDartError(Dart_LoadLibrary(importName, source, Dart_Null()));
  }
  CheckDartError(Dart_LibraryImportLibrary(libraryHandle, importHandle));
  DART_RETURN(Dart_Null());
}

/** Executes _seedEnv([map], [newVars]) within the context of [library]. */
DART_FUNCTION(InitEnvMap) {
  DART_ARGS_2(library, map);
  Dart_Handle libraryHandle = get_library(library);
  CheckDartError(Dart_Invoke(libraryHandle, Dart_NewString("_seedEnv"), 1, &map));
  DART_RETURN(Dart_Null());
}

DART_LIBRARY(sandbox)
  EXPORT(Declare, 3);
  EXPORT(NewLibrary, 2);
  EXPORT(Invoke, 2);
  EXPORT(Import, 3);
  EXPORT(InitEnvMap, 2);
DART_LIBRARY_END
