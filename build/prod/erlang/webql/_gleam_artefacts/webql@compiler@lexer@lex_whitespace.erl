-module(webql@compiler@lexer@lex_whitespace).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_whitespace.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_whitespace.gleam", 11).
-spec lex_whitespace(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_whitespace(Bytes, Start, Size) ->
    case Bytes of
        <<" "/utf8, Rest/binary>> ->
            lex_whitespace(Rest, Start, Size + 1);

        <<"\t"/utf8, Rest/binary>> ->
            lex_whitespace(Rest, Start, Size + 1);

        <<"\n"/utf8, Rest/binary>> ->
            lex_whitespace(Rest, Start, Size + 1);

        <<"\r"/utf8, Rest/binary>> ->
            lex_whitespace(Rest, Start, Size + 1);

        _ ->
            {{token, space, {span, Start, Start + Size}}, Bytes}
    end.

-file("src/webql/compiler/lexer/lex_whitespace.gleam", 5).
?DOC(" Lexes contiguous whitespace (spaces, tabs, newlines).\n").
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_whitespace(Bytes, Start, Size).
