-module(webql@compiler@parser@parse_parameter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_parameter.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_parameter.gleam", 41).
-spec parse_separator(list(webql@compiler@lexer@token:token())) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_separator(Tokens) ->
    case Tokens of
        [{token, colon, _} | Rest] ->
            {ok, Rest};

        [{token, Kind, Span} | _] ->
            {error, {diagnostic, {unexpected_token, Kind}, Span}};

        [] ->
            {error, {diagnostic, unexpected_eof, {span, 0, 0}}}
    end.

-file("src/webql/compiler/parser/parse_parameter.gleam", 29).
-spec parse_key(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {binary(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_key(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, Span} | Rest] ->
            {ok, {webql@compiler@source:slice(Source, Span), Span, Rest}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Tokens@1) -> parse_key(Source, Tokens@1) end
            )
    end.

-file("src/webql/compiler/parser/parse_parameter.gleam", 10).
?DOC(" Parses a graph parameter.\n").
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:parameter(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    gleam@result:'try'(
        parse_key(Source, Tokens),
        fun(Key) ->
            {Name, Key_span, Rest} = Key,
            gleam@result:'try'(
                parse_separator(Rest),
                fun(Rest@1) ->
                    gleam@result:'try'(
                        webql@compiler@parser@parse_port:parse(Source, Rest@1),
                        fun(_use0) ->
                            {Port, Span, Rest@2} = _use0,
                            Span@1 = webql@compiler@source:cover(Key_span, Span),
                            {ok,
                                {{parameter, Name, Port, Span@1},
                                    Span@1,
                                    Rest@2}}
                        end
                    )
                end
            )
        end
    ).
