-module(webql@compiler@parser@parse_value).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_value.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_value.gleam", 54).
-spec parse_string(binary(), webql@compiler@source:span()) -> binary().
parse_string(Source, Span) ->
    gleam@string:slice(
        Source,
        erlang:element(2, Span) + 1,
        (erlang:element(3, Span) - erlang:element(2, Span)) - 2
    ).

-file("src/webql/compiler/parser/parse_value.gleam", 76).
-spec parse_float(binary(), webql@compiler@source:span()) -> {ok,
        webql@compiler@parser@ast:value()} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_float(Source, Span) ->
    Literal = webql@compiler@source:slice(Source, Span),
    case gleam_stdlib:parse_float(Literal) of
        {ok, Value} ->
            {ok, {float, <<"Float"/utf8>>, Value, Span}};

        {error, _} ->
            {error, {diagnostic, {unexpected_token, float}, Span}}
    end.

-file("src/webql/compiler/parser/parse_value.gleam", 62).
-spec parse_int(binary(), webql@compiler@source:span()) -> {ok,
        webql@compiler@parser@ast:value()} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_int(Source, Span) ->
    Literal = webql@compiler@source:slice(Source, Span),
    case gleam_stdlib:parse_int(Literal) of
        {ok, Value} ->
            {ok, {int, <<"Int"/utf8>>, Value, Span}};

        {error, _} ->
            {error, {diagnostic, {unexpected_token, int}, Span}}
    end.

-file("src/webql/compiler/parser/parse_value.gleam", 24).
?DOC(
    " Parses a literal value.\n"
    "\n"
    " ## Examples\n"
    "\n"
    "     1\n"
    "     1.23\n"
    "     \"test\"\n"
).
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:value(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, int, Span} | Rest] ->
            gleam@result:'try'(
                parse_int(Source, Span),
                fun(Value) -> {ok, {Value, Span, Rest}} end
            );

        [{token, float, Span@1} | Rest@1] ->
            gleam@result:'try'(
                parse_float(Source, Span@1),
                fun(Value@1) -> {ok, {Value@1, Span@1, Rest@1}} end
            );

        [{token, string, Span@2} | Rest@2] ->
            Value@2 = parse_string(Source, Span@2),
            {ok, {{string, <<"String"/utf8>>, Value@2, Span@2}, Span@2, Rest@2}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Tokens@1) -> parse(Source, Tokens@1) end
            )
    end.
