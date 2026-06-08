-module(webql@compiler@parser@parse_supernode).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_supernode.gleam").
-export([parse/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_supernode.gleam", 46).
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

-file("src/webql/compiler/parser/parse_supernode.gleam", 31).
-spec parse_supernode_name(
    binary(),
    {binary(),
        webql@compiler@source:span(),
        list(webql@compiler@lexer@token:token())},
    fun((binary(), list(webql@compiler@lexer@token:token())) -> {ok,
            {webql@compiler@parser@ast:graph(),
                webql@compiler@source:span(),
                list(webql@compiler@lexer@token:token())}} |
        {error, webql@compiler@parser@diagnostic:diagnostic()})
) -> {ok,
        {webql@compiler@parser@ast:node_(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_supernode_name(Source, Name, Parse_graph) ->
    {Name@1, Name_span, Rest} = Name,
    gleam@result:'try'(
        parse_equal(Source, Rest),
        fun(Rest@1) ->
            gleam@result:'try'(
                Parse_graph(Source, Rest@1),
                fun(_use0) ->
                    {Graph, Graph_span, Rest@2} = _use0,
                    Span = {span,
                        erlang:element(2, Name_span),
                        erlang:element(3, Graph_span)},
                    {ok, {{supernode, Name@1, Graph, Span}, Span, Rest@2}}
                end
            )
        end
    ).

-file("src/webql/compiler/parser/parse_supernode.gleam", 9).
?DOC(" Parses a nested graph supernode.\n").
-spec parse(
    binary(),
    list(webql@compiler@lexer@token:token()),
    fun((binary(), list(webql@compiler@lexer@token:token())) -> {ok,
            {webql@compiler@parser@ast:graph(),
                webql@compiler@source:span(),
                list(webql@compiler@lexer@token:token())}} |
        {error, webql@compiler@parser@diagnostic:diagnostic()})
) -> {ok,
        {webql@compiler@parser@ast:node_(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens, Parse_graph) ->
    case Tokens of
        [{token, upper_identifier, Span} | Rest] ->
            Name = {webql@compiler@source:slice(Source, Span), Span, Rest},
            parse_supernode_name(Source, Name, Parse_graph);

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@1) -> parse(Source, Rest@1, Parse_graph) end
            )
    end.
