-module(webql@compiler@lowerer@lower_source).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_source.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_source.gleam", 6).
?DOC(" Lowers a resolved source into an IR source.\n").
-spec lower(webql@compiler@resolver@hir:source()) -> webql@graph:source().
lower(Source) ->
    case Source of
        {output, Path, _, _} ->
            {output, Path};

        {literal, Value, _, _} ->
            {literal, webql@compiler@lowerer@lower_value:lower(Value)}
    end.
