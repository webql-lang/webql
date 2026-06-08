-module(webql@compiler@lexer).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer.gleam").
-export([new/1, lex/1, with_comments/2, with_whitespace/2, with_mode/2]).
-export_type([lexer_mode/0, lexer/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type lexer_mode() :: halt | recover.

-opaque lexer() :: {lexer,
        binary(),
        bitstring(),
        bitstring(),
        integer(),
        lexer_mode(),
        boolean(),
        boolean()}.

-file("src/webql/compiler/lexer.gleam", 39).
?DOC(" Creates a new lexer instance from a source.\n").
-spec new(binary()) -> lexer().
new(Source) ->
    Bytes = gleam_stdlib:identity(Source),
    {lexer, Source, Bytes, Bytes, 0, halt, true, true}.

-file("src/webql/compiler/lexer.gleam", 101).
-spec lex_token(lexer()) -> {webql@compiler@lexer@token:token(), bitstring()}.
lex_token(Lexer) ->
    case erlang:element(4, Lexer) of
        <<"0"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"1"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"2"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"3"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"4"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"5"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"6"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"7"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"8"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"9"/utf8, Rest/binary>> ->
            webql@compiler@lexer@lex_number:lex(
                Rest,
                erlang:element(5, Lexer),
                1
            );

        <<"\""/utf8, Rest@1/binary>> ->
            webql@compiler@lexer@lex_string:lex(
                Rest@1,
                erlang:element(5, Lexer),
                1
            );

        <<"#"/utf8, Rest@2/binary>> ->
            webql@compiler@lexer@lex_comment:lex(
                Rest@2,
                erlang:element(5, Lexer),
                1
            );

        <<"("/utf8, Rest@3/binary>> ->
            {{token,
                    l_paren,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@3};

        <<")"/utf8, Rest@4/binary>> ->
            {{token,
                    r_paren,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@4};

        <<"{"/utf8, Rest@5/binary>> ->
            {{token,
                    l_brace,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@5};

        <<"}"/utf8, Rest@6/binary>> ->
            {{token,
                    r_brace,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@6};

        <<"["/utf8, Rest@7/binary>> ->
            {{token,
                    l_square,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@7};

        <<"]"/utf8, Rest@8/binary>> ->
            {{token,
                    r_square,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@8};

        <<":"/utf8, Rest@9/binary>> ->
            {{token,
                    colon,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@9};

        <<","/utf8, Rest@10/binary>> ->
            {{token,
                    comma,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@10};

        <<"="/utf8, Rest@11/binary>> ->
            {{token,
                    equal,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@11};

        <<"."/utf8, Rest@12/binary>> ->
            {{token,
                    dot,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@12};

        <<"->"/utf8, Rest@13/binary>> ->
            {{token,
                    r_arrow,
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 2}},
                Rest@13};

        <<"A"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"B"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"C"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"D"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"E"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"F"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"G"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"H"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"I"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"J"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"K"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"L"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"M"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"N"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"O"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"P"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"Q"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"R"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"S"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"T"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"U"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"V"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"W"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"X"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"Y"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"Z"/utf8, Rest@14/binary>> ->
            webql@compiler@lexer@lex_upper_identifier:lex(
                Rest@14,
                erlang:element(5, Lexer),
                1
            );

        <<"a"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"b"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"c"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"d"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"e"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"f"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"g"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"h"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"i"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"j"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"k"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"l"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"m"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"n"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"o"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"p"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"q"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"r"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"s"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"t"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"u"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"v"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"w"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"x"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"y"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<"z"/utf8, Rest@15/binary>> ->
            webql@compiler@lexer@lex_lower_identifier:lex(
                Rest@15,
                erlang:element(5, Lexer),
                1
            );

        <<" "/utf8, Rest@16/binary>> ->
            webql@compiler@lexer@lex_whitespace:lex(
                Rest@16,
                erlang:element(5, Lexer),
                1
            );

        <<"\n"/utf8, Rest@16/binary>> ->
            webql@compiler@lexer@lex_whitespace:lex(
                Rest@16,
                erlang:element(5, Lexer),
                1
            );

        <<"\r"/utf8, Rest@16/binary>> ->
            webql@compiler@lexer@lex_whitespace:lex(
                Rest@16,
                erlang:element(5, Lexer),
                1
            );

        <<"\t"/utf8, Rest@16/binary>> ->
            webql@compiler@lexer@lex_whitespace:lex(
                Rest@16,
                erlang:element(5, Lexer),
                1
            );

        <<_, Rest@17/binary>> ->
            {{token,
                    {diagnostic, illegal_token},
                    {span,
                        erlang:element(5, Lexer),
                        erlang:element(5, Lexer) + 1}},
                Rest@17};

        _ ->
            {{token,
                    e_o_f,
                    {span, erlang:element(5, Lexer), erlang:element(5, Lexer)}},
                <<>>}
    end.

-file("src/webql/compiler/lexer.gleam", 292).
-spec lex_token_or_error(lexer()) -> {ok,
        {webql@compiler@lexer@token:token(), bitstring()}} |
    {error, webql@compiler@lexer@diagnostic:diagnostic()}.
lex_token_or_error(Lexer) ->
    case lex_token(Lexer) of
        {{token, {diagnostic, Kind}, Span}, _} ->
            {error, {diagnostic, Kind, Span}};

        Token ->
            {ok, Token}
    end.

-file("src/webql/compiler/lexer.gleam", 80).
-spec lex_source(lexer(), list(webql@compiler@lexer@token:token())) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@lexer@diagnostic:diagnostic()}.
lex_source(Lexer, Tokens) ->
    gleam@result:'try'(case erlang:element(6, Lexer) of
            recover ->
                {ok, lex_token(Lexer)};

            halt ->
                lex_token_or_error(Lexer)
        end, fun(_use0) ->
            {Token, Rest} = _use0,
            Lexer@1 = {lexer,
                erlang:element(2, Lexer),
                erlang:element(3, Lexer),
                Rest,
                erlang:element(3, erlang:element(3, Token)),
                erlang:element(6, Lexer),
                erlang:element(7, Lexer),
                erlang:element(8, Lexer)},
            case erlang:element(2, Token) of
                e_o_f ->
                    {ok, [Token | Tokens]};

                comment_single when not erlang:element(7, Lexer@1) ->
                    lex_source(Lexer@1, Tokens);

                space when not erlang:element(8, Lexer@1) ->
                    lex_source(Lexer@1, Tokens);

                _ ->
                    lex_source(Lexer@1, [Token | Tokens])
            end
        end).

-file("src/webql/compiler/lexer.gleam", 54).
?DOC(" Takes a lexer source and converts it to a list of tokens.\n").
-spec lex(lexer()) -> {ok, list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@lexer@diagnostic:diagnostic()}.
lex(Lexer) ->
    Tokens = [],
    case lex_source(Lexer, Tokens) of
        {ok, Result} ->
            {ok, lists:reverse(Result)};

        {error, Message} ->
            {error, Message}
    end.

-file("src/webql/compiler/lexer.gleam", 64).
?DOC(" Configures comments on an active lexer instance\n").
-spec with_comments(lexer(), boolean()) -> lexer().
with_comments(Lexer, Comments) ->
    {lexer,
        erlang:element(2, Lexer),
        erlang:element(3, Lexer),
        erlang:element(4, Lexer),
        erlang:element(5, Lexer),
        erlang:element(6, Lexer),
        Comments,
        erlang:element(8, Lexer)}.

-file("src/webql/compiler/lexer.gleam", 69).
?DOC(" Configures whitespace on an active lexer instance\n").
-spec with_whitespace(lexer(), boolean()) -> lexer().
with_whitespace(Lexer, Whitespace) ->
    {lexer,
        erlang:element(2, Lexer),
        erlang:element(3, Lexer),
        erlang:element(4, Lexer),
        erlang:element(5, Lexer),
        erlang:element(6, Lexer),
        erlang:element(7, Lexer),
        Whitespace}.

-file("src/webql/compiler/lexer.gleam", 74).
?DOC(" Configures stictness on an active lexer instance.\n").
-spec with_mode(lexer(), lexer_mode()) -> lexer().
with_mode(Lexer, Mode) ->
    {lexer,
        erlang:element(2, Lexer),
        erlang:element(3, Lexer),
        erlang:element(4, Lexer),
        erlang:element(5, Lexer),
        Mode,
        erlang:element(7, Lexer),
        erlang:element(8, Lexer)}.
