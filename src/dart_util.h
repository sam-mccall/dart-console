// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#ifdef DART_UTIL_H
#error dart_util.h should only be included once per translation unit, in the extension implementation file
#endif
#define DART_UTIL_H

#include "dart_api.h"

static Dart_Handle _library; // XXX this shouldn't be defined here

#define DART_ARG(name, i) Dart_Handle name = Dart_GetNativeArgument(arguments, i);
#ifdef DEBUG
#define DART_ARGS_0() Dart_EnterScope(); printf("Native %s\n", __FUNCTION__); \
  for (int i = 0; i < Dart_GetNativeArgumentCount(arguments); i++) { \
    Dart_Handle argStringHandle = Dart_ToString(Dart_GetNativeArgument(arguments, i)); \
    const char* text = "<exception converting to string>"; \
    if (!Dart_IsError(argStringHandle)) Dart_StringToCString(argStringHandle, &text); \
    printf("  %d: %s\n", i, text); \
  }
#else
#define DART_ARGS_0() Dart_EnterScope();
#endif
#define DART_ARGS_1(arg0) DART_ARGS_0() DART_ARG(arg0, 0)
#define DART_ARGS_2(arg0, arg1) DART_ARGS_1(arg0); DART_ARG(arg1, 1)
#define DART_ARGS_3(arg0, arg1, arg2) DART_ARGS_2(arg0, arg1); DART_ARG(arg2, 2)
#define DART_ARGS_4(arg0, arg1, arg2, arg3) DART_ARGS_3(arg0, arg1, arg2); DART_ARG(arg3, 3)

#define DART_FUNCTION(name) static void name(Dart_NativeArguments arguments)
#define DART_RETURN(expr) {Dart_SetReturnValue(arguments, expr); Dart_ExitScope(); return;}
#define Throw(message) _Throw(_library, message)
#define CheckDartError(handle) _CheckDartError(_library, handle)

static void _Throw(Dart_Handle library, const char* message) {
  Dart_Handle messageHandle = Dart_NewString(message);
  Dart_Handle exceptionClass = Dart_GetClass(library, Dart_NewString("Exception"));
  Dart_Handle exception = Dart_New(exceptionClass, Dart_Null(), 1, &messageHandle);
  if (Dart_IsError(exception) && !Dart_ErrorHasException(exception)) {
    printf("Failed to throw exception: %s\n", Dart_GetError(exception));
    exit(1);
  }
  Dart_ThrowException(exception);
}

static Dart_Handle _CheckDartError(Dart_Handle library, Dart_Handle result) {
  if (Dart_IsError(result)) {
    if (Dart_ErrorHasException(result)) {
      Dart_ThrowException(Dart_ErrorGetException(result));
    } else {
      _Throw(library, Dart_GetError(result));
    }
  } else {
    return result;
  }
}

#define EXPORT(func, args) if (!strcmp(#func, cname) && argc == args) { return func; }
#define DART_LIBRARY(libname) \
  static Dart_NativeFunction ResolveName(Dart_Handle name, int argc); \
  DART_EXPORT Dart_Handle dart_ ## libname ##_Init(Dart_Handle parent_library) { \
    if (Dart_IsError(parent_library)) { return parent_library; } \
    Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName); \
    if (Dart_IsError(result_code)) return result_code; \
    _library = Dart_NewPersistentHandle(parent_library); \
    return parent_library; \
  } \
  static Dart_NativeFunction ResolveName(Dart_Handle name, int argc) { \
    assert(Dart_IsString8(name)); \
    const char* cname; \
    Dart_Handle check_error = Dart_StringToCString(name, &cname); \
    if (Dart_IsError(check_error)) Dart_PropagateError(check_error);
#define DART_LIBRARY_END \
    return NULL; \
  }
