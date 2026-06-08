-module(webql@compiler@lexer@lex_comment).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/lex_comment.gleam").
-export([lex/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lexer/lex_comment.gleam", 11).
-spec lex_comment(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex_comment(Bytes, Start, Size) ->
    case Bytes of
        <<"\r\n"/utf8, _/binary>> ->
            {{token, comment_single, {span, Start, Start + Size}}, Bytes};

        <<"\n"/utf8, _/binary>> ->
            {{token, comment_single, {span, Start, Start + Size}}, Bytes};

        <<"\r"/utf8, _/binary>> ->
            {{token, comment_single, {span, Start, Start + Size}}, Bytes};

        <<_, Rest/binary>> ->
            lex_comment(Rest, Start, Size + 1);

        _ ->
            {{token, comment_single, {span, Start, Start + Size}}, Bytes}
    end.

-file("src/webql/compiler/lexer/lex_comment.gleam", 5).
?DOC(" Lexes single line comments beginning with '#'.\n").
-spec lex(bitstring(), integer(), integer()) -> {webql@compiler@lexer@token:token(),
    bitstring()}.
lex(Bytes, Start, Size) ->
    lex_comment(Bytes, Start, Size).
