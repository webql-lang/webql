-module(webql@compiler@resolver@resolve_edge).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_edge.gleam").
-export([resolve/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_edge.gleam", 13).
?DOC(" Resolves an edge declaration.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:edge(),
    webql@compiler@reference:edge()
) -> {ok, webql@compiler@resolver@hir:edge()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Edge, Reference) ->
    {edge, Source, Target, Span} = Edge,
    gleam@result:'try'(
        webql@compiler@resolver@resolve_source:resolve(
            Environment,
            Context,
            Source
        ),
        fun(Source@1) ->
            gleam@result:'try'(
                webql@compiler@resolver@resolve_target:resolve(Context, Target),
                fun(Target@1) ->
                    gleam@bool:guard(
                        gleam@result:is_ok(
                            webql@compiler@context:get_edge(
                                Context,
                                erlang:element(3, Target@1)
                            )
                        ),
                        {error,
                            {diagnostic,
                                {duplicate_edge_input,
                                    erlang:element(2, Target@1)},
                                Span}},
                        fun() ->
                            {ok, {edge, Source@1, Target@1, Reference, Span}}
                        end
                    )
                end
            )
        end
    ).
