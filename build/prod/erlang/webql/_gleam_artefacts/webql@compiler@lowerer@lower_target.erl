-module(webql@compiler@lowerer@lower_target).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_target.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_target.gleam", 5).
?DOC(" Lowers a resolved target into an IR target.\n").
-spec lower(webql@compiler@resolver@hir:target()) -> webql@graph:target().
lower(Target) ->
    {input, erlang:element(2, Target)}.
