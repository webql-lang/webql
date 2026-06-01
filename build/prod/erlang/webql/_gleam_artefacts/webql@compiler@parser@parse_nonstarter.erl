-module(webql@compiler@parser@parse_nonstarter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_nonstarter.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_nonstarter.gleam", 42).
-spec parse_nonstarter(list(webql@compiler@lexer@token:token())) -> list(webql@compiler@lexer@token:token()).
parse_nonstarter(Tokens) ->
    case Tokens of
        [{token, space, _} | Rest] ->
            parse_nonstarter(Rest);

        [{token, comment_single, _} | Rest] ->
            parse_nonstarter(Rest);

        _ ->
            Tokens
    end.

-file("src/webql/compiler/parser/parse_nonstarter.gleam", 8).
?DOC(
    " Handles non-starter tokens (ie. spaces and comments) that have no material effect on parsing.\n"
    " If the remaining tokens still are invalid, returns an unexpected token or EOF diagnostic.\n"
).
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    Bytes = gleam_stdlib:identity(Source),
    Byte_length = erlang:byte_size(Bytes),
    case Tokens of
        [{token, space, _} | Rest] ->
            {ok, parse_nonstarter(Rest)};

        [{token, comment_single, _} | Rest] ->
            {ok, parse_nonstarter(Rest)};

        [{token, e_o_f, _} | _] ->
            {error,
                {diagnostic, unexpected_eof, {span, Byte_length, Byte_length}}};

        [Token | _] ->
            {error,
                {diagnostic,
                    {unexpected_token, erlang:element(2, Token)},
                    erlang:element(3, Token)}};

        [] ->
            {error,
                {diagnostic, unexpected_eof, {span, Byte_length, Byte_length}}}
    end.
