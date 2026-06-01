-module(webql@compiler@typechecker@typecheck_document).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/typechecker/typecheck_document.gleam").
-export([typecheck/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/typechecker/typecheck_document.gleam", 49).
-spec typecheck_edges(
    webql@compiler@context:context(),
    list(webql@compiler@resolver@hir:edge())
) -> {ok, nil} | {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
typecheck_edges(Context, Edges) ->
    case Edges of
        [Edge | Rest] ->
            gleam@result:'try'(
                webql@compiler@typechecker@typecheck_edge:typecheck(
                    Edge,
                    Context
                ),
                fun(_) -> typecheck_edges(Context, Rest) end
            );

        [] ->
            {ok, nil}
    end.

-file("src/webql/compiler/typechecker/typecheck_document.gleam", 38).
-spec get_context(
    webql@compiler@context:context(),
    webql@compiler@reference:supernode(),
    webql@compiler@source:span()
) -> {ok, webql@compiler@context:context()} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
get_context(Context, Reference, Span) ->
    case webql@compiler@context:get_context(Context, Reference) of
        {ok, Context@1} ->
            {ok, Context@1};

        {error, _} ->
            {error, {diagnostic, {unknown_supernode, Reference}, Span}}
    end.

-file("src/webql/compiler/typechecker/typecheck_document.gleam", 23).
-spec typecheck_supernodes(
    webql@compiler@context:context(),
    list(webql@compiler@resolver@hir:node_())
) -> {ok, nil} | {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
typecheck_supernodes(Context, Nodes) ->
    case Nodes of
        [{supernode, _, Graph, Reference, Span} | Rest] ->
            gleam@result:'try'(
                get_context(Context, Reference, Span),
                fun(Nested_context) ->
                    gleam@result:'try'(
                        typecheck_graph(Nested_context, Graph),
                        fun(_) -> typecheck_supernodes(Context, Rest) end
                    )
                end
            );

        [{node, _, _, _, _, _} | Rest@1] ->
            typecheck_supernodes(Context, Rest@1);

        [] ->
            {ok, nil}
    end.

-file("src/webql/compiler/typechecker/typecheck_document.gleam", 18).
-spec typecheck_graph(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:graph()
) -> {ok, nil} | {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
typecheck_graph(Context, Graph) ->
    gleam@result:'try'(
        typecheck_supernodes(Context, erlang:element(4, Graph)),
        fun(_) -> typecheck_edges(Context, erlang:element(5, Graph)) end
    ).

-file("src/webql/compiler/typechecker/typecheck_document.gleam", 8).
?DOC(" Typechecks a resolved document against its context.\n").
-spec typecheck(
    webql@compiler@resolver@hir:document(),
    webql@compiler@context:context()
) -> {ok, webql@compiler@resolver@hir:document()} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
typecheck(Document, Context) ->
    gleam@result:'try'(
        typecheck_graph(Context, erlang:element(2, Document)),
        fun(_) -> {ok, Document} end
    ).
