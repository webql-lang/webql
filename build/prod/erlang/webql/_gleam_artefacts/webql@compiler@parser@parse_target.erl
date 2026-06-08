-module(webql@compiler@parser@parse_target).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_target.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_target.gleam", 96).
-spec parse_graph_input(
    binary(),
    {nil,
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:target(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_graph_input(Source, Dot) ->
    {_, Dot_span, Rest} = Dot,
    case Rest of
        [{token, lower_identifier, Span} | Rest@1] ->
            Name = webql@compiler@source:slice(Source, Span),
            Span@1 = webql@compiler@source:cover(Dot_span, Span),
            {ok, {{input, [Name], Span@1}, Span@1, Rest@1}};

        [{token, Kind, Span@2} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@2}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_target.gleam", 65).
-spec parse_node_input(
    binary(),
    {binary(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:target(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_node_input(Source, Alias) ->
    {Alias@1, Alias_span, Rest} = Alias,
    case Rest of
        [{token, lower_identifier, Span} | Rest@1] ->
            Name = webql@compiler@source:slice(Source, Span),
            Span@1 = webql@compiler@source:cover(Alias_span, Span),
            {ok, {{input, [Alias@1, Name], Span@1}, Span@1, Rest@1}};

        [{token, Kind, Span@2} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@2}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_target.gleam", 38).
-spec parse_node_target(
    binary(),
    {binary(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())}
) -> {ok,
        {webql@compiler@parser@ast:target(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_node_target(Source, Alias) ->
    {Name, Span, Rest} = Alias,
    case Rest of
        [{token, dot, _} | Rest@1] ->
            parse_node_input(Source, {Name, Span, Rest@1});

        [{token, Kind, Span@1} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span@1}};

        [] ->
            Length = string:length(Source),
            {error, {diagnostic, unexpected_eof, {span, Length, Length}}}
    end.

-file("src/webql/compiler/parser/parse_target.gleam", 10).
?DOC(" Parses an edge target.\n").
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:target(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, Span} | Rest] ->
            Name = {webql@compiler@source:slice(Source, Span), Span, Rest},
            parse_node_target(Source, Name);

        [{token, dot, Span@1} | Rest@1] ->
            Dot = {nil, Span@1, Rest@1},
            parse_graph_input(Source, Dot);

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@2) -> parse(Source, Rest@2) end
            )
    end.
