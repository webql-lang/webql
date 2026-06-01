-module(webql@compiler@resolver@register_edge).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/register_edge.gleam").
-export([register/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/register_edge.gleam", 5).
?DOC(" Registers a edge.\n").
-spec register(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:edge()
) -> webql@compiler@context:context().
register(Context, Edge) ->
    webql@compiler@context:add_edge(
        Context,
        erlang:element(3, erlang:element(3, Edge))
    ).
