-module(webql@compiler@parser@parse_source).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_source.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_source.gleam", 131).
-spec parse_literal(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:source(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_literal(Source, Tokens) ->
    gleam@result:'try'(
        webql@compiler@parser@parse_value:parse(Source, Tokens),
        fun(_use0) ->
            {Value, Span, Rest} = _use0,
            {ok, {{literal, Value, Span}, Span, Rest}}
        end
    ).

-file("src/webql/compiler/parser/parse_source.gleam", 100).
-spec parse_graph_output(
    binary(),
    {nil,
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:source(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_graph_output(Source, Dot) ->
    {_, Dot_span, Rest} = Dot,
    case Rest of
        [{token, lower_identifier, Span} | Rest@1] ->
            Name = webql@compiler@source:slice(Source, Span),
            Span@1 = webql@compiler@source:cover(Dot_span, Span),
            {ok, {{output, [Name], Span@1}, Span@1, Rest@1}};

        [{token, Kind, Span@2} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@2}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_source.gleam", 69).
-spec parse_node_output(
    binary(),
    {binary(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:source(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_node_output(Source, Alias) ->
    {Alias@1, Alias_span, Rest} = Alias,
    case Rest of
        [{token, lower_identifier, Span} | Rest@1] ->
            Name = webql@compiler@source:slice(Source, Span),
            Span@1 = webql@compiler@source:cover(Alias_span, Span),
            {ok, {{output, [Alias@1, Name], Span@1}, Span@1, Rest@1}};

        [{token, Kind, Span@2} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@2}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_source.gleam", 42).
-spec parse_node_source(
    binary(),
    {binary(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:source(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_node_source(Source, Alias) ->
    {Name, Span, Rest} = Alias,
    case Rest of
        [{token, dot, _} | Rest@1] ->
            parse_node_output(Source, {Name, Span, Rest@1});

        [{token, Kind, Span@1} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@1}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_source.gleam", 11).
?DOC(" Parses an edge source.\n").
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:source(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, Span} | Rest] ->
            Alias = {webql@compiler@source:slice(Source, Span), Span, Rest},
            parse_node_source(Source, Alias);

        [{token, dot, Span@1} | Rest@1] ->
            Dot = {nil, Span@1, Rest@1},
            parse_graph_output(Source, Dot);

        [{token, int, _} | _] ->
            parse_literal(Source, Tokens);

        [{token, float, _} | _] ->
            parse_literal(Source, Tokens);

        [{token, string, _} | _] ->
            parse_literal(Source, Tokens);

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@2) -> parse(Source, Rest@2) end
            )
    end.
