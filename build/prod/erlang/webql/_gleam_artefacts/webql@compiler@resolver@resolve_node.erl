-module(webql@compiler@resolver@resolve_node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_node.gleam").
-export([resolve/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_node.gleam", 101).
-spec register_supernode_operation(
    webql@compiler@environment:environment(),
    binary(),
    webql@compiler@resolver@hir:graph()
) -> webql@compiler@environment:environment().
register_supernode_operation(Environment, Name, Graph) ->
    Operation = webql@compiler@environment:next_operation(Environment),
    Environment@1 = webql@compiler@environment:add_operation(Environment, Name),
    Environment@3 = gleam@list:fold(
        erlang:element(2, Graph),
        Environment@1,
        fun(Environment@2, Parameter) ->
            webql@compiler@environment:add_input(
                Environment@2,
                Operation,
                {erlang:element(2, Parameter),
                    erlang:element(3, erlang:element(3, Parameter))}
            )
        end
    ),
    gleam@list:fold(
        erlang:element(3, Graph),
        Environment@3,
        fun(Environment@4, Return) ->
            webql@compiler@environment:add_output(
                Environment@4,
                Operation,
                {erlang:element(2, Return),
                    erlang:element(3, erlang:element(3, Return))}
            )
        end
    ).

-file("src/webql/compiler/resolver/resolve_node.gleam", 61).
-spec resolve_supernode(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    binary(),
    webql@compiler@parser@ast:graph(),
    webql@compiler@source:span(),
    fun((webql@compiler@environment:environment(), webql@compiler@context:context(), webql@compiler@parser@ast:graph()) -> {ok,
            {webql@compiler@resolver@hir:graph(),
                webql@compiler@context:context()}} |
        {error, webql@compiler@resolver@diagnostic:diagnostic()})
) -> {ok,
        {webql@compiler@resolver@hir:node_(),
            webql@compiler@context:context(),
            webql@compiler@environment:environment()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_supernode(Environment, Context, Name, Graph, Span, Resolve_graph) ->
    gleam@bool:guard(
        gleam@result:is_ok(
            webql@compiler@environment:get_operation(Environment, Name)
        ),
        {error, {diagnostic, {duplicate_supernode, Name}, Span}},
        fun() ->
            Reference = webql@compiler@context:next_supernode(Context),
            gleam@result:'try'(
                Resolve_graph(
                    Environment,
                    {context,
                        maps:new(),
                        erlang:element(3, Context),
                        maps:new(),
                        maps:new(),
                        maps:new(),
                        maps:new(),
                        maps:new(),
                        erlang:element(9, Context)},
                    Graph
                ),
                fun(_use0) ->
                    {Graph@1, Sub_context} = _use0,
                    Supernode = {supernode, Name, Graph@1, Reference, Span},
                    Context@1 = webql@compiler@resolver@register_supernode:register(
                        Context,
                        Name,
                        Reference,
                        Sub_context
                    ),
                    Environment@1 = register_supernode_operation(
                        Environment,
                        Name,
                        Graph@1
                    ),
                    {ok, {Supernode, Context@1, Environment@1}}
                end
            )
        end
    ).

-file("src/webql/compiler/resolver/resolve_node.gleam", 32).
-spec resolve_node(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    binary(),
    binary(),
    webql@compiler@source:span()
) -> {ok,
        {webql@compiler@resolver@hir:node_(),
            webql@compiler@context:context(),
            webql@compiler@environment:environment()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_node(Environment, Context, Name, Node, Span) ->
    gleam@bool:guard(
        gleam@result:is_ok(webql@compiler@context:get_node(Context, Name)),
        {error, {diagnostic, {duplicate_node, Name}, Span}},
        fun() ->
            case webql@compiler@environment:get_operation(Environment, Node) of
                {ok, Operation} ->
                    Reference = webql@compiler@context:next_node(Context),
                    Node@1 = {node, Name, Node, Operation, Reference, Span},
                    Context@1 = webql@compiler@resolver@register_node:register(
                        Environment,
                        Context,
                        Node@1
                    ),
                    {ok, {Node@1, Context@1, Environment}};

                {error, _} ->
                    {error, {diagnostic, {unknown_node, Node}, Span}}
            end
        end
    ).

-file("src/webql/compiler/resolver/resolve_node.gleam", 14).
?DOC(" Resolves a node declaration.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:node_(),
    fun((webql@compiler@environment:environment(), webql@compiler@context:context(), webql@compiler@parser@ast:graph()) -> {ok,
            {webql@compiler@resolver@hir:graph(),
                webql@compiler@context:context()}} |
        {error, webql@compiler@resolver@diagnostic:diagnostic()})
) -> {ok,
        {webql@compiler@resolver@hir:node_(),
            webql@compiler@context:context(),
            webql@compiler@environment:environment()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Node, Resolve_graph) ->
    case Node of
        {node, Name, Node@1, Span} ->
            resolve_node(Environment, Context, Name, Node@1, Span);

        {supernode, Name@1, Graph, Span@1} ->
            resolve_supernode(
                Environment,
                Context,
                Name@1,
                Graph,
                Span@1,
                Resolve_graph
            )
    end.
