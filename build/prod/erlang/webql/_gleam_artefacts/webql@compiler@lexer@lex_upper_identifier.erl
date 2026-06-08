-module(webql@compiler@lexer@lex_upper_identifier).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_upper_identifier.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_upper_identifier.gleam", 11).
-spec lex_upper_identifier(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_upper_identifier(Bytes, Start, Size) ->
    case Bytes of
        <<"A"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"B"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"C"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"D"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"E"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"F"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"G"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"H"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"I"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"J"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"K"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"L"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"M"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"N"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"O"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"P"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"Q"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"R"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"S"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"T"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"U"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"V"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"W"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"X"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"Y"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"Z"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"a"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"b"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"c"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"d"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"e"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"f"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"g"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"h"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"i"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"j"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"k"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"l"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"m"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"n"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"o"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"p"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"q"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"r"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"s"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"t"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"u"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"v"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"w"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"x"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"y"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"z"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"0"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"1"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"2"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"3"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"4"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"5"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"6"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"7"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"8"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        <<"9"/utf8, Rest/binary>> ->
            lex_upper_identifier(Rest, Start, Size + 1);

        _ ->
            End = Start + Size,
            {{token, upper_identifier, {span, Start, End}}, Bytes}
    end.

-file("src/webql/compiler/lexer/lex_upper_identifier.gleam", 5).
?DOC(" Lexes upper identifiers.\n").
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_upper_identifier(Bytes, Start, Size).
