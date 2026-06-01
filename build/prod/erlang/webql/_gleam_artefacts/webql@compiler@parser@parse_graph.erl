-module(webql@compiler@parser@parse_graph).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_graph.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_graph.gleam", 128).
-spec parse_left_brace(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        list(webql@compiler@lexer@token:token())} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_left_brace(Source, Tokens) ->
    case Tokens of
        [{token, l_brace, _} | Rest] ->
            {ok, Rest};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@1) -> parse_left_brace(Source, Rest@1) end
            )
    end.

-file("src/webql/compiler/parser/parse_graph.gleam", 88).
-spec parse_returns(
    binary(),
    list(webql@compiler@lexer@token:token()),
    list(webql@compiler@parser@ast:return())
) -> {ok,
        {list(webql@compiler@parser@ast:return()),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_returns(Source, Tokens, Returns) ->
    case Tokens of
        [{token, lower_identifier, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_return:parse(Source, Tokens),
                fun(_use0) ->
                    {Return, _, Rest} = _use0,
                    parse_returns(Source, Rest, [Return | Returns])
                end
            );

        [{token, comma, _} | Rest@1] ->
            parse_returns(Source, Rest@1, Returns);

        [{token, l_brace, Span} | _] ->
            {ok, {Returns, Span, Tokens}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@2) -> parse_returns(Source, Rest@2, Returns) end
            )
    end.

-file("src/webql/compiler/parser/parse_graph.gleam", 60).
-spec parse_parameters(
    binary(),
    list(webql@compiler@lexer@token:token()),
    list(webql@compiler@parser@ast:parameter())
) -> {ok,
        {list(webql@compiler@parser@ast:parameter()),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_parameters(Source, Tokens, Parameters) ->
    case Tokens of
        [{token, lower_identifier, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_parameter:parse(Source, Tokens),
                fun(_use0) ->
                    {Parameter, _, Rest} = _use0,
                    parse_parameters(Source, Rest, [Parameter | Parameters])
                end
            );

        [{token, comma, _} | Rest@1] ->
            parse_parameters(Source, Rest@1, Parameters);

        [{token, r_arrow, Span} | Rest@2] ->
            {ok, {Parameters, Span, Rest@2}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@3) -> parse_parameters(Source, Rest@3, Parameters) end
            )
    end.

-file("src/webql/compiler/parser/parse_graph.gleam", 178).
-spec parse_lower_block_body(
    binary(),
    list(webql@compiler@lexer@token:token()),
    list(webql@compiler@parser@ast:node_()),
    list(webql@compiler@parser@ast:edge())
) -> {ok,
        {{list(webql@compiler@parser@ast:node_()),
                list(webql@compiler@parser@ast:edge())},
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_lower_block_body(Source, Tokens, Nodes, Edges) ->
    case Tokens of
        [{token, lower_identifier, _}, {token, equal, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_node:parse(Source, Tokens),
                fun(_use0) ->
                    {Node, _, Rest} = _use0,
                    parse_block_body(Source, Rest, [Node | Nodes], Edges)
                end
            );

        [{token, lower_identifier, _}, {token, dot, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_edge:parse(Source, Tokens),
                fun(_use0@1) ->
                    {Edge, _, Rest@1} = _use0@1,
                    parse_block_body(Source, Rest@1, Nodes, [Edge | Edges])
                end
            );

        [{token, lower_identifier, _} = Identifier | Rest@2] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Rest@2),
                fun(Rest@3) ->
                    parse_lower_block_body(
                        Source,
                        [Identifier | Rest@3],
                        Nodes,
                        Edges
                    )
                end
            );

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@4) ->
                    parse_block_body(Source, Rest@4, Nodes, Edges)
                end
            )
    end.

-file("src/webql/compiler/parser/parse_graph.gleam", 139).
-spec parse_block_body(
    binary(),
    list(webql@compiler@lexer@token:token()),
    list(webql@compiler@parser@ast:node_()),
    list(webql@compiler@parser@ast:edge())
) -> {ok,
        {{list(webql@compiler@parser@ast:node_()),
                list(webql@compiler@parser@ast:edge())},
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_block_body(Source, Tokens, Nodes, Edges) ->
    case Tokens of
        [{token, r_brace, Span} | Rest] ->
            {ok, {{Nodes, Edges}, Span, Rest}};

        [{token, upper_identifier, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_supernode:parse(
                    Source,
                    Tokens,
                    fun parse/2
                ),
                fun(_use0) ->
                    {Node, _, Rest@1} = _use0,
                    parse_block_body(Source, Rest@1, [Node | Nodes], Edges)
                end
            );

        [{token, lower_identifier, _} | _] ->
            parse_lower_block_body(Source, Tokens, Nodes, Edges);

        [{token, dot, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_edge:parse(Source, Tokens),
                fun(_use0@1) ->
                    {Edge, _, Rest@2} = _use0@1,
                    parse_block_body(Source, Rest@2, Nodes, [Edge | Edges])
                end
            );

        [{token, int, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_edge:parse(Source, Tokens),
                fun(_use0@1) ->
                    {Edge, _, Rest@2} = _use0@1,
                    parse_block_body(Source, Rest@2, Nodes, [Edge | Edges])
                end
            );

        [{token, float, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_edge:parse(Source, Tokens),
                fun(_use0@1) ->
                    {Edge, _, Rest@2} = _use0@1,
                    parse_block_body(Source, Rest@2, Nodes, [Edge | Edges])
                end
            );

        [{token, string, _} | _] ->
            gleam@result:'try'(
                webql@compiler@parser@parse_edge:parse(Source, Tokens),
                fun(_use0@1) ->
                    {Edge, _, Rest@2} = _use0@1,
                    parse_block_body(Source, Rest@2, Nodes, [Edge | Edges])
                end
            );

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest@3) ->
                    parse_block_body(Source, Rest@3, Nodes, Edges)
                end
            )
    end.

-file("src/webql/compiler/parser/parse_graph.gleam", 115).
-spec parse_body(
    binary(),
    list(webql@compiler@lexer@token:token()),
    list(webql@compiler@parser@ast:node_()),
    list(webql@compiler@parser@ast:edge())
) -> {ok,
        {{list(webql@compiler@parser@ast:node_()),
                list(webql@compiler@parser@ast:edge())},
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_body(Source, Tokens, Nodes, Edges) ->
    gleam@result:'try'(
        parse_left_brace(Source, Tokens),
        fun(Tokens@1) -> parse_block_body(Source, Tokens@1, Nodes, Edges) end
    ).

-file("src/webql/compiler/parser/parse_graph.gleam", 34).
-spec parse_graph(binary(), list(webql@compiler@lexer@token:token()), integer()) -> {ok,
        {webql@compiler@parser@ast:graph(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse_graph(Source, Tokens, Start) ->
    gleam@result:'try'(
        parse_parameters(Source, Tokens, []),
        fun(_use0) ->
            {Parameters, _, Rest} = _use0,
            gleam@result:'try'(
                parse_returns(Source, Rest, []),
                fun(_use0@1) ->
                    {Returns, _, Rest@1} = _use0@1,
                    gleam@result:'try'(
                        parse_body(Source, Rest@1, [], []),
                        fun(_use0@2) ->
                            {{Nodes, Edges}, Span, Rest@2} = _use0@2,
                            Span@1 = {span, Start, erlang:element(3, Span)},
                            {ok,
                                {{graph,
                                        lists:reverse(Parameters),
                                        lists:reverse(Returns),
                                        lists:reverse(Nodes),
                                        lists:reverse(Edges),
                                        Span@1},
                                    Span@1,
                                    Rest@2}}
                        end
                    )
                end
            )
        end
    ).

-file("src/webql/compiler/parser/parse_graph.gleam", 15).
?DOC(" Parses a graph.\n").
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:graph(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, lower_identifier, Span} | _] ->
            parse_graph(Source, Tokens, erlang:element(2, Span));

        [{token, dot, Span} | _] ->
            parse_graph(Source, Tokens, erlang:element(2, Span));

        [{token, r_arrow, Span} | _] ->
            parse_graph(Source, Tokens, erlang:element(2, Span));

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Rest) -> parse(Source, Rest) end
            )
    end.
