-module(webql@compiler@resolver@resolve_document).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_document.gleam").
-export([resolve/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_document.gleam", 11).
?DOC(" Resolves a top-level document.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:document(),
    webql@compiler@reference:document()
) -> {ok,
        {webql@compiler@resolver@hir:document(),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Document, Reference) ->
    gleam@result:'try'(
        webql@compiler@resolver@resolve_graph:resolve(
            Environment,
            Context,
            erlang:element(2, Document)
        ),
        fun(_use0) ->
            {Graph, Context@1} = _use0,
            {ok,
                {{document, Graph, Reference, erlang:element(3, Document)},
                    Context@1}}
        end
    ).
