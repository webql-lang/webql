-module(webql@compiler@lexer@lex_string).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_string.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_string.gleam", 50).
-spec lex_escape_string(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_escape_string(Bytes, Start, Size) ->
    case Bytes of
        <<_, Rest/binary>> ->
            lex_string(Rest, Start, Size + 2);

        _ ->
            End = (Start + Size) + 1,
            {{token, {diagnostic, unterminated_string}, {span, Start, End}},
                Bytes}
    end.

-file("src/webql/compiler/lexer/lex_string.gleam", 12).
-spec lex_string(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_string(Bytes, Start, Size) ->
    case Bytes of
        <<"\""/utf8, Rest/binary>> ->
            End = (Start + Size) + 1,
            {{token, string, {span, Start, End}}, Rest};

        <<"\\"/utf8, Rest@1/binary>> ->
            lex_escape_string(Rest@1, Start, Size);

        <<_, Rest@2/binary>> ->
            lex_string(Rest@2, Start, Size + 1);

        _ ->
            {{token,
                    {diagnostic, unterminated_string},
                    {span, Start, Start + Size}},
                <<>>}
    end.

-file("src/webql/compiler/lexer/lex_string.gleam", 6).
?DOC(" Lexes string values.\n").
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_string(Bytes, Start, Size).
