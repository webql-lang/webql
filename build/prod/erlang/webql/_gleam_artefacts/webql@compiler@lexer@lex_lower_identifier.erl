-module(webql@compiler@lexer@lex_lower_identifier).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_lower_identifier.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_lower_identifier.gleam", 11).
-spec lex_lower_identifier(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_lower_identifier(Bytes, Start, Size) ->
    case Bytes of
        <<"a"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"b"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"c"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"d"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"e"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"f"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"g"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"h"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"i"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"j"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"k"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"l"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"m"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"n"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"o"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"p"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"q"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"r"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"s"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"t"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"u"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"v"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"w"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"x"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"y"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"z"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"0"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"1"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"2"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"3"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"4"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"5"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"6"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"7"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"8"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"9"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        <<"_"/utf8, Rest/binary>> ->
            lex_lower_identifier(Rest, Start, Size + 1);

        _ ->
            End = Start + Size,
            {{token, lower_identifier, {span, Start, End}}, Bytes}
    end.

-file("src/webql/compiler/lexer/lex_lower_identifier.gleam", 5).
?DOC(" Lexes upper identifiers.\n").
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_lower_identifier(Bytes, Start, Size).
