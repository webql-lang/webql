-module(webql@compiler@lexer@lex_number).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_number.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_number.gleam", 14).
-spec lex_number(
    bitstring(),
    webql@compiler@lexer@token:token_kind(),
    integer(),
    integer()
) -> {webql@compiler@lexer@token:token(), bitstring()}.
lex_number(Bytes, Kind, Start, Size) ->
    case Bytes of
        <<"_"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"0"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"1"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"2"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"3"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"4"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"5"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"6"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"7"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"8"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"9"/utf8, Rest/binary>> ->
            lex_number(Rest, Kind, Start, Size + 1);

        <<"."/utf8, Rest@1/binary>> ->
            lex_number(Rest@1, float, Start, Size + 1);

        Next_bytes ->
            {{token, Kind, {span, Start, Start + Size}}, Next_bytes}
    end.

-file("src/webql/compiler/lexer/lex_number.gleam", 8).
?DOC(
    " Lexes number values.\n"
    " By default the number lexer assumes it is parsing an integer.\n"
).
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_number(Bytes, int, Start, Size).
