-module(webql@compiler@resolver).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver.gleam").
-export([new/1, resolve/3]).
-export_type([resolver/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque resolver() :: {resolver, webql@compiler@parser@ast:document()}.

-file("src/webql/compiler/resolver.gleam", 14).
?DOC(" Creates a new resolver instance from a parser document.\n").
-spec new(webql@compiler@parser@ast:document()) -> resolver().
new(Document) ->
    {resolver, Document}.

-file("src/webql/compiler/resolver.gleam", 19).
?DOC(" Resolves a resolver instance.\n").
-spec resolve(
    resolver(),
    webql@compiler@environment:environment(),
    webql@compiler@context:context()
) -> {ok,
        {webql@compiler@resolver@hir:document(),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Resolver, Environment, Context) ->
    Reference = {document, 0},
    webql@compiler@resolver@resolve_document:resolve(
        Environment,
        Context,
        erlang:element(2, Resolver),
        Reference
    ).
