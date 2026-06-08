-module(webql@compiler@parser@parse_node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_node.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_node.gleam", 40).
-spec parse_node(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {binary(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_node(Source, Tokens) ->
    case Tokens of
        [{token, upper_identifier, Span} | Rest] ->
            {ok, {webql@compiler@source:slice(Source, Span), Span, Rest}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Tokens@1) -> parse_node(Source, Tokens@1) end
            )
    end.

-file("src/webql/compiler/parser/parse_node.gleam", 52).
-spec parse_equal(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_equal(Source, Tokens) ->
    case Tokens of
        [{token, equal, _} | Rest] ->
            {ok, Rest};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@1) -> parse_equal(Source, Rest@1) end
            )
    end.

-file("src/webql/compiler/parser/parse_node.gleam", 14).
?DOC(
    " Parses a node inside a graph body.\n"
    "\n"
    " ## Examples\n"
    "\n"
    "     m = Math\n"
    "     value = \"hello world\"\n"
).
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:node_(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, Span} | Rest] ->
            Name = webql@compiler@source:slice(Source, Span),
            Name_span = Span,
            gleam@result:'try'(
                parse_equal(Source, Rest),
                fun(Rest@1) ->
                    gleam@result:'try'(
                        parse_node(Source, Rest@1),
                        fun(_use0) ->
                            {Node, Node_span, Rest@2} = _use0,
                            Span@1 = webql@compiler@source:cover(
                                Name_span,
                                Node_span
                            ),
                            {ok, {{node, Name, Node, Span@1}, Span@1, Rest@2}}
                        end
                    )
                end
            );

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@3) -> parse(Source, Rest@3) end
            )
    end.
