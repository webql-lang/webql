-module(webql@compiler@resolver@resolve_source).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_source.gleam").
-export([resolve/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_source.gleam", 37).
-spec resolve_literal(
    webql@compiler@environment:environment(),
    webql@compiler@parser@ast:value(),
    webql@compiler@source:span()
) -> {ok, webql@compiler@resolver@hir:source()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_literal(Environment, Value, Span) ->
    case webql@compiler@environment:get_port(
        Environment,
        erlang:element(2, Value)
    ) of
        {ok, Port} ->
            Value@1 = webql@compiler@resolver@resolve_value:resolve(Value),
            {ok, {literal, Value@1, Port, Span}};

        {error, _} ->
            {error,
                {diagnostic, {unknown_port, erlang:element(2, Value)}, Span}}
    end.

-file("src/webql/compiler/resolver/resolve_source.gleam", 24).
-spec resolve_output(
    webql@compiler@context:context(),
    list(binary()),
    webql@compiler@source:span()
) -> {ok, webql@compiler@resolver@hir:source()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_output(Context, Path, Span) ->
    case webql@compiler@context:get_output(Context, Path) of
        {ok, {Reference, _}} ->
            {ok, {output, Path, Reference, Span}};

        {error, _} ->
            {error, {diagnostic, {unknown_output, Path}, Span}}
    end.

-file("src/webql/compiler/resolver/resolve_source.gleam", 10).
?DOC(" Resolves an edge source.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:source()
) -> {ok, webql@compiler@resolver@hir:source()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Source) ->
    case Source of
        {output, Path, Span} ->
            resolve_output(Context, Path, Span);

        {literal, Value, Span@1} ->
            resolve_literal(Environment, Value, Span@1)
    end.
