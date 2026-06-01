-module(webql@compiler@parser@parse_edge).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_edge.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_edge.gleam", 37).
-spec parse_arrow(
    binary(),
    {webql@compiler@parser@ast:source(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:edge(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_arrow(Document, Source) ->
    {Source@1, Source_span, Rest} = Source,
    case Rest of
        [{token, r_arrow, _} | Rest@1] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_target:parse(Document, Rest@1),
                fun(Target) ->
                    {Target@1, Target_span, Rest@2} = Target,
                    Span = webql@compiler@source:cover(Source_span, Target_span),
                    {ok, {{edge, Source@1, Target@1, Span}, Span, Rest@2}}
                end
            );

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Document, Rest),
                fun(Rest@3) ->
                    parse_arrow(Document, {Source@1, Source_span, Rest@3})
                end
            )
    end.

-file("src/webql/compiler/parser/parse_edge.gleam", 32).
-spec parse_edge_source(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:edge(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_edge_source(Document, Tokens) ->
    gleam@result:'try'(
        webql@compiler@parser@parse_source:parse(Document, Tokens),
        fun(Source) -> parse_arrow(Document, Source) end
    ).

-file("src/webql/compiler/parser/parse_edge.gleam", 11).
?DOC(" Parses an edge inside a graph body.\n").
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:edge(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Document, Tokens) ->
    case Tokens of
        [{token, lower_identifier, _} | _] ->
            parse_edge_source(Document, Tokens);

        [{token, dot, _} | _] ->
            parse_edge_source(Document, Tokens);

        [{token, int, _} | _] ->
            parse_edge_source(Document, Tokens);

        [{token, float, _} | _] ->
            parse_edge_source(Document, Tokens);

        [{token, string, _} | _] ->
            parse_edge_source(Document, Tokens);

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Document, Tokens),
                fun(Rest) -> parse(Document, Rest) end
            )
    end.
