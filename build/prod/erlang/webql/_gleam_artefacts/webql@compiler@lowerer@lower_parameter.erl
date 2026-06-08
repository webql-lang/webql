-module(webql@compiler@lowerer@lower_parameter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_parameter.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_parameter.gleam", 5).
?DOC(" Lowers a resolved graph parameter into an IR input.\n").
-spec lower(webql@compiler@resolver@hir:parameter()) -> webql@graph:parameter().
lower(Parameter) ->
    {parameter,
        erlang:element(2, Parameter),
        erlang:element(2, erlang:element(3, Parameter))}.
