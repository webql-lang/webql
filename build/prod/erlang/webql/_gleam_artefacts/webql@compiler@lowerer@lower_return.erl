-module(webql@compiler@lowerer@lower_return).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_return.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_return.gleam", 5).
?DOC(" Lowers a resolved graph return into an IR output.\n").
-spec lower(webql@compiler@resolver@hir:return()) -> webql@graph:return().
lower(Return) ->
    {return,
        erlang:element(2, Return),
        erlang:element(2, erlang:element(3, Return))}.
