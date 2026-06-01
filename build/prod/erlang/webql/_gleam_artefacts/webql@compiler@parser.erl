-module(webql@compiler@parser).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser.gleam").
-export([new/2, parse/1]).
-export_type([parser/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque parser() :: {parser, binary(), list(webql@compiler@lexer@token:token())}.

-file("src/webql/compiler/parser.gleam", 13).
?DOC(" Creates a new parser instance from a source.\n").
-spec new(binary(), list(webql@compiler@lexer@token:token())) -> parser().
new(Source, Tokens) ->
    {parser, Source, Tokens}.

-file("src/webql/compiler/parser.gleam", 28).
-spec parse_eof(
    binary(),
    list(webql@compiler@lexer@token:token()),
    webql@compiler@parser@ast:document()
) -> {ok, webql@compiler@parser@ast:document()} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_eof(Source, Tokens, Document) ->
    case Tokens of
        [{token, e_o_f, _}] ->
            {ok, Document};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest) -> parse_eof(Source, Rest, Document) end
            )
    end.

-file("src/webql/compiler/parser.gleam", 18).
?DOC(" Parses tokens into AST.\n").
-spec parse(parser()) -> {ok, webql@compiler@parser@ast:document()} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Parser) ->
    gleam@result:'try'(
        webql@compiler@parser@parse_document:parse(
            erlang:element(2, Parser),
            erlang:element(3, Parser)
        ),
        fun(_use0) ->
            {Document, _, Rest} = _use0,
            parse_eof(erlang:element(2, Parser), Rest, Document)
        end
    ).
