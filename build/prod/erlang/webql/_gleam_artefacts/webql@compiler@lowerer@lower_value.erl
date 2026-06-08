-module(webql@compiler@lowerer@lower_value).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_value.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_value.gleam", 5).
?DOC(" Lowers a resolved value into an IR literal value.\n").
-spec lower(webql@compiler@resolver@hir:value()) -> webql@graph:value().
lower(Value) ->
    case Value of
        {int, _, Value@1, _} ->
            {int, Value@1};

        {float, _, Value@2, _} ->
            {float, Value@2};

        {string, _, Value@3, _} ->
            {string, Value@3}
    end.
