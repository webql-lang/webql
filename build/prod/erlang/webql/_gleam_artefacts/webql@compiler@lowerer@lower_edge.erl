-module(webql@compiler@lowerer@lower_edge).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_edge.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_edge.gleam", 7).
?DOC(" Lowers a resolved edge into an IR edge.\n").
-spec lower(webql@compiler@resolver@hir:edge()) -> webql@graph:edge().
lower(Edge) ->
    {edge,
        webql@compiler@lowerer@lower_source:lower(erlang:element(2, Edge)),
        webql@compiler@lowerer@lower_target:lower(erlang:element(3, Edge))}.
