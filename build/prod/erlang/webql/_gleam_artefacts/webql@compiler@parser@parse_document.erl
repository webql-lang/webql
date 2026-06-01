-module(webql@compiler@parser@parse_document).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_document.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_document.gleam", 37).
-spec parse_document(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:document(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_document(Source, Tokens) ->
    gleam@result:'try'(
        webql@compiler@parser@parse_graph:parse(Source, Tokens),
        fun(_use0) ->
            {Graph, Span, Rest} = _use0,
            {ok, {{document, Graph, Span}, Span, Rest}}
        end
    ).

-file("src/webql/compiler/parser/parse_document.gleam", 15).
?DOC(
    " Parses a document.\n"
    "\n"
    " ## Examples\n"
    "\n"
    "     in: Int -> out: Int { ... }\n"
    "     -> out: Int { ... }\n"
).
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:document(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, _} | _] ->
            parse_document(Source, Tokens);

        [{token, dot, _} | _] ->
            parse_document(Source, Tokens);

        [{token, r_arrow, _} | _] ->
            parse_document(Source, Tokens);

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Remaining) -> parse(Source, Remaining) end
            )
    end.
