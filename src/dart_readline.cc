// Copyright 2012 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

#include <string.h>
#include <stdio.h>

#include "dart_api.h"
#include <readline/readline.h>
#include <readline/history.h>
#include <stdlib.h>

#define DART_ARG(name, i) Dart_Handle name = Dart_GetNativeArgument(arguments, i);
#ifdef DEBUG
#define DART_ARGS_0() Dart_EnterScope(); printf("Entering %s\n", __FUNCTION__);
#else
#define DART_ARGS_0() Dart_EnterScope();
#endif
#define DART_ARGS_1(arg0) DART_ARGS_0() DART_ARG(arg0, 0)
#define DART_ARGS_2(arg0, arg1) DART_ARGS_1(arg0); DART_ARG(arg1, 1)
#define DART_ARGS_3(arg0, arg1, arg2) DART_ARGS_2(arg0, arg1); DART_ARG(arg2, 2)
#define DART_ARGS_4(arg0, arg1, arg2, arg3) DART_ARGS_3(arg0, arg1, arg2); DART_ARG(arg3, 3)

#define DART_FUNCTION(name) static void name(Dart_NativeArguments arguments)
#define DART_RETURN(expr) {Dart_SetReturnValue(arguments, expr); Dart_ExitScope(); return;}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc);

static Dart_Handle library;

DART_EXPORT Dart_Handle dart_readline_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) { return parent_library; }

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName);
  if (Dart_IsError(result_code)) return result_code;

  library = Dart_NewPersistentHandle(parent_library);
  return parent_library;
}

static void Throw(const char* message) {
  Dart_Handle messageHandle = Dart_NewString(message);
  Dart_ThrowException(Dart_Invoke(library, Dart_NewString("_newException"), 1, &messageHandle));
}

static Dart_Handle CheckDartError(Dart_Handle result) {
  if (Dart_IsError(result)) Throw(Dart_GetError(result));
  return result;
}

DART_FUNCTION(Readline) {
  DART_ARGS_1(prompt);

  const char* cprompt;
  CheckDartError(Dart_StringToCString(prompt, &cprompt));
  char* cresult = readline(cprompt);
  if (!cresult) {
    printf("\n");
    DART_RETURN(Dart_Null());
  }

  Dart_Handle result = Dart_NewString(cresult);
  free(cresult);

  DART_RETURN(result);
}

DART_FUNCTION(History_Add) {
  DART_ARGS_1(text);

  const char* ctext;
  CheckDartError(Dart_StringToCString(text, &ctext));
  add_history(ctext);

  DART_RETURN(Dart_Null());
}

#define EXPORT(func, args) if (!strcmp(#func, cname) && argc == args) { return func; }
Dart_NativeFunction ResolveName(Dart_Handle name, int argc) {
  assert(Dart_IsString8(name));
  const char* cname;
  Dart_Handle check_error = Dart_StringToCString(name, &cname);
  if (Dart_IsError(check_error)) Dart_PropagateError(check_error);

  EXPORT(Readline, 1);
  EXPORT(History_Add, 1);
  return NULL;
}
