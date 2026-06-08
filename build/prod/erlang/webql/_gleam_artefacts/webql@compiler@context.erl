-module(webql@compiler@context).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/context.gleam").
-export([new/0, next_node/1, add_node/2, add_nodes/2, next_supernode/1, add_supernode/2, add_supernodes/2, next_edge/1, add_edge/2, add_edges/2, next_input/1, add_input/3, add_inputs/2, next_output/1, add_output/3, add_outputs/2, next_parameter/1, add_parameter/2, add_parameters/2, next_return/1, add_return/2, add_returns/2, add_context/3, add_contexts/2, get_input/2, get_output/2, get_node/2, get_supernode/2, get_edge/2, get_parameter/2, get_return/2, get_context/2]).
-export_type([context/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type context() :: {context,
        gleam@dict:dict(binary(), webql@compiler@reference:node_()),
        gleam@dict:dict(binary(), webql@compiler@reference:supernode()),
        gleam@dict:dict(webql@compiler@reference:input(), webql@compiler@reference:edge()),
        gleam@dict:dict(list(binary()), {webql@compiler@reference:input(),
            webql@compiler@reference:port_()}),
        gleam@dict:dict(list(binary()), {webql@compiler@reference:output(),
            webql@compiler@reference:port_()}),
        gleam@dict:dict(binary(), webql@compiler@reference:parameter()),
        gleam@dict:dict(binary(), webql@compiler@reference:return()),
        gleam@dict:dict(webql@compiler@reference:supernode(), context())}.

-file("src/webql/compiler/context.gleam", 20).
?DOC(" Creates a new context.\n").
-spec new() -> context().
new() ->
    {context,
        maps:new(),
        maps:new(),
        maps:new(),
        maps:new(),
        maps:new(),
        maps:new(),
        maps:new(),
        maps:new()}.

-file("src/webql/compiler/context.gleam", 224).
?DOC(" Gets the next stable node reference.\n").
-spec next_node(context()) -> webql@compiler@reference:node_().
next_node(Context) ->
    {node, maps:size(erlang:element(2, Context))}.

-file("src/webql/compiler/context.gleam", 34).
?DOC(" Adds a node to the current context instance.\n").
-spec add_node(context(), binary()) -> context().
add_node(Context, Node) ->
    {context, Nodes, _, _, _, _, _, _, _} = Context,
    {context, gleam@dict:upsert(Nodes, Node, fun(Node@1) -> case Node@1 of
                    {some, Node@2} ->
                        Node@2;

                    none ->
                        next_node(Context)
                end end), erlang:element(3, Context), erlang:element(4, Context), erlang:element(
            5,
            Context
        ), erlang:element(6, Context), erlang:element(7, Context), erlang:element(
            8,
            Context
        ), erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 49).
?DOC(" Adds nodes to the current context instance.\n").
-spec add_nodes(context(), list(binary())) -> context().
add_nodes(Context, Nodes) ->
    gleam@list:fold(Nodes, Context, fun add_node/2).

-file("src/webql/compiler/context.gleam", 229).
?DOC(" Gets the next stable supernode reference.\n").
-spec next_supernode(context()) -> webql@compiler@reference:supernode().
next_supernode(Context) ->
    {supernode, maps:size(erlang:element(3, Context))}.

-file("src/webql/compiler/context.gleam", 54).
?DOC(" Adds a supernode to the current context instance.\n").
-spec add_supernode(context(), binary()) -> context().
add_supernode(Context, Supernode) ->
    {context, _, Supernodes, _, _, _, _, _, _} = Context,
    {context,
        erlang:element(2, Context),
        gleam@dict:upsert(
            Supernodes,
            Supernode,
            fun(Supernode@1) -> case Supernode@1 of
                    {some, Supernode@2} ->
                        Supernode@2;

                    none ->
                        next_supernode(Context)
                end end
        ),
        erlang:element(4, Context),
        erlang:element(5, Context),
        erlang:element(6, Context),
        erlang:element(7, Context),
        erlang:element(8, Context),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 69).
?DOC(" Adds supernodes to the current context instance.\n").
-spec add_supernodes(context(), list(binary())) -> context().
add_supernodes(Context, Supernodes) ->
    gleam@list:fold(Supernodes, Context, fun add_supernode/2).

-file("src/webql/compiler/context.gleam", 234).
?DOC(" Gets the next stable edge reference.\n").
-spec next_edge(context()) -> webql@compiler@reference:edge().
next_edge(Context) ->
    {edge, maps:size(erlang:element(4, Context))}.

-file("src/webql/compiler/context.gleam", 74).
?DOC(" Adds an edge to the current context instance.\n").
-spec add_edge(context(), webql@compiler@reference:input()) -> context().
add_edge(Context, Edge) ->
    {context, _, _, Edges, _, _, _, _, _} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        gleam@dict:upsert(Edges, Edge, fun(Edge@1) -> case Edge@1 of
                    {some, Edge@2} ->
                        Edge@2;

                    none ->
                        next_edge(Context)
                end end),
        erlang:element(5, Context),
        erlang:element(6, Context),
        erlang:element(7, Context),
        erlang:element(8, Context),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 89).
?DOC(" Adds edges to the current context instance.\n").
-spec add_edges(context(), list(webql@compiler@reference:input())) -> context().
add_edges(Context, Edges) ->
    gleam@list:fold(Edges, Context, fun add_edge/2).

-file("src/webql/compiler/context.gleam", 239).
?DOC(" Gets the next stable input reference.\n").
-spec next_input(context()) -> webql@compiler@reference:input().
next_input(Context) ->
    {input, maps:size(erlang:element(5, Context))}.

-file("src/webql/compiler/context.gleam", 94).
?DOC(" Adds a typed input to the current context instance.\n").
-spec add_input(context(), list(binary()), webql@compiler@reference:port_()) -> context().
add_input(Context, Input, Port) ->
    {context, _, _, _, Inputs, _, _, _, _} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        erlang:element(4, Context),
        gleam@dict:upsert(Inputs, Input, fun(Input@1) -> case Input@1 of
                    {some, Input@2} ->
                        Input@2;

                    none ->
                        {next_input(Context), Port}
                end end),
        erlang:element(6, Context),
        erlang:element(7, Context),
        erlang:element(8, Context),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 113).
?DOC(" Adds typed inputs to the current context instance.\n").
-spec add_inputs(
    context(),
    list({list(binary()), webql@compiler@reference:port_()})
) -> context().
add_inputs(Context, Inputs) ->
    gleam@list:fold(
        Inputs,
        Context,
        fun(Context@1, Input) ->
            {Path, Port} = Input,
            add_input(Context@1, Path, Port)
        end
    ).

-file("src/webql/compiler/context.gleam", 244).
?DOC(" Gets the next stable output reference.\n").
-spec next_output(context()) -> webql@compiler@reference:output().
next_output(Context) ->
    {output, maps:size(erlang:element(6, Context))}.

-file("src/webql/compiler/context.gleam", 124).
?DOC(" Adds a typed output to the current context instance.\n").
-spec add_output(context(), list(binary()), webql@compiler@reference:port_()) -> context().
add_output(Context, Output, Port) ->
    {context, _, _, _, _, Outputs, _, _, _} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        erlang:element(4, Context),
        erlang:element(5, Context),
        gleam@dict:upsert(Outputs, Output, fun(Output@1) -> case Output@1 of
                    {some, Output@2} ->
                        Output@2;

                    none ->
                        {next_output(Context), Port}
                end end),
        erlang:element(7, Context),
        erlang:element(8, Context),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 143).
?DOC(" Adds typed outputs to the current context instance.\n").
-spec add_outputs(
    context(),
    list({list(binary()), webql@compiler@reference:port_()})
) -> context().
add_outputs(Context, Outputs) ->
    gleam@list:fold(
        Outputs,
        Context,
        fun(Context@1, Output) ->
            {Path, Port} = Output,
            add_output(Context@1, Path, Port)
        end
    ).

-file("src/webql/compiler/context.gleam", 265).
?DOC(" Gets the next stable parameter reference.\n").
-spec next_parameter(context()) -> webql@compiler@reference:parameter().
next_parameter(Context) ->
    {parameter, maps:size(erlang:element(7, Context))}.

-file("src/webql/compiler/context.gleam", 154).
?DOC(" Adds a parameter to the current context instance.\n").
-spec add_parameter(context(), binary()) -> context().
add_parameter(Context, Parameter) ->
    {context, _, _, _, _, _, Parameters, _, _} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        erlang:element(4, Context),
        erlang:element(5, Context),
        erlang:element(6, Context),
        gleam@dict:upsert(
            Parameters,
            Parameter,
            fun(Parameter@1) -> case Parameter@1 of
                    {some, Parameter@2} ->
                        Parameter@2;

                    none ->
                        next_parameter(Context)
                end end
        ),
        erlang:element(8, Context),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 169).
?DOC(" Adds parameters to the current context instance.\n").
-spec add_parameters(context(), list(binary())) -> context().
add_parameters(Context, Parameters) ->
    gleam@list:fold(Parameters, Context, fun add_parameter/2).

-file("src/webql/compiler/context.gleam", 270).
?DOC(" Gets the next stable return reference.\n").
-spec next_return(context()) -> webql@compiler@reference:return().
next_return(Context) ->
    {return, maps:size(erlang:element(8, Context))}.

-file("src/webql/compiler/context.gleam", 174).
?DOC(" Adds a return to the current context instance.\n").
-spec add_return(context(), binary()) -> context().
add_return(Context, Return) ->
    {context, _, _, _, _, _, _, Returns, _} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        erlang:element(4, Context),
        erlang:element(5, Context),
        erlang:element(6, Context),
        erlang:element(7, Context),
        gleam@dict:upsert(Returns, Return, fun(Return@1) -> case Return@1 of
                    {some, Return@2} ->
                        Return@2;

                    none ->
                        next_return(Context)
                end end),
        erlang:element(9, Context)}.

-file("src/webql/compiler/context.gleam", 189).
?DOC(" Adds returns to the current context instance.\n").
-spec add_returns(context(), list(binary())) -> context().
add_returns(Context, Returns) ->
    gleam@list:fold(Returns, Context, fun add_return/2).

-file("src/webql/compiler/context.gleam", 194).
?DOC(" Adds a nested context to the current context instance.\n").
-spec add_context(context(), webql@compiler@reference:supernode(), context()) -> context().
add_context(Context, Supernode, Nested_context) ->
    {context, _, _, _, _, _, _, _, Contexts} = Context,
    {context,
        erlang:element(2, Context),
        erlang:element(3, Context),
        erlang:element(4, Context),
        erlang:element(5, Context),
        erlang:element(6, Context),
        erlang:element(7, Context),
        erlang:element(8, Context),
        gleam@dict:upsert(
            Contexts,
            Supernode,
            fun(Existing_context) -> case Existing_context of
                    {some, Existing_context@1} ->
                        Existing_context@1;

                    none ->
                        Nested_context
                end end
        )}.

-file("src/webql/compiler/context.gleam", 213).
?DOC(" Adds nested contexts to the current context instance.\n").
-spec add_contexts(
    context(),
    list({webql@compiler@reference:supernode(), context()})
) -> context().
add_contexts(Context, Contexts) ->
    gleam@list:fold(
        Contexts,
        Context,
        fun(Context@1, Entry) ->
            {Supernode, Nested_context} = Entry,
            add_context(Context@1, Supernode, Nested_context)
        end
    ).

-file("src/webql/compiler/context.gleam", 249).
?DOC(" Looks up a typed input by path.\n").
-spec get_input(context(), list(binary())) -> {ok,
        {webql@compiler@reference:input(), webql@compiler@reference:port_()}} |
    {error, nil}.
get_input(Context, Path) ->
    gleam_stdlib:map_get(erlang:element(5, Context), Path).

-file("src/webql/compiler/context.gleam", 257).
?DOC(" Looks up a typed output by path.\n").
-spec get_output(context(), list(binary())) -> {ok,
        {webql@compiler@reference:output(), webql@compiler@reference:port_()}} |
    {error, nil}.
get_output(Context, Path) ->
    gleam_stdlib:map_get(erlang:element(6, Context), Path).

-file("src/webql/compiler/context.gleam", 275).
?DOC(" Looks up a node reference by name.\n").
-spec get_node(context(), binary()) -> {ok, webql@compiler@reference:node_()} |
    {error, nil}.
get_node(Context, Node) ->
    gleam_stdlib:map_get(erlang:element(2, Context), Node).

-file("src/webql/compiler/context.gleam", 280).
?DOC(" Looks up a supernode reference by name.\n").
-spec get_supernode(context(), binary()) -> {ok,
        webql@compiler@reference:supernode()} |
    {error, nil}.
get_supernode(Context, Supernode) ->
    gleam_stdlib:map_get(erlang:element(3, Context), Supernode).

-file("src/webql/compiler/context.gleam", 288).
?DOC(" Looks up an edge reference by input reference.\n").
-spec get_edge(context(), webql@compiler@reference:input()) -> {ok,
        webql@compiler@reference:edge()} |
    {error, nil}.
get_edge(Context, Input) ->
    gleam_stdlib:map_get(erlang:element(4, Context), Input).

-file("src/webql/compiler/context.gleam", 296).
?DOC(" Looks up a parameter reference by name.\n").
-spec get_parameter(context(), binary()) -> {ok,
        webql@compiler@reference:parameter()} |
    {error, nil}.
get_parameter(Context, Parameter) ->
    gleam_stdlib:map_get(erlang:element(7, Context), Parameter).

-file("src/webql/compiler/context.gleam", 304).
?DOC(" Looks up a return reference by name.\n").
-spec get_return(context(), binary()) -> {ok, webql@compiler@reference:return()} |
    {error, nil}.
get_return(Context, Return) ->
    gleam_stdlib:map_get(erlang:element(8, Context), Return).

-file("src/webql/compiler/context.gleam", 312).
?DOC(" Looks up a nested context by supernode reference.\n").
-spec get_context(context(), webql@compiler@reference:supernode()) -> {ok,
        context()} |
    {error, nil}.
get_context(Context, Supernode) ->
    gleam_stdlib:map_get(erlang:element(9, Context), Supernode).
