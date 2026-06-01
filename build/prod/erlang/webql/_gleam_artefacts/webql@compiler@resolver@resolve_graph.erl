-module(webql@compiler@resolver@resolve_graph).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_graph.gleam").
-export([resolve/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 194).
-spec resolve_edges(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    list(webql@compiler@parser@ast:edge())
) -> {ok,
        {list(webql@compiler@resolver@hir:edge()),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_edges(Environment, Context, Edges) ->
    case Edges of
        [Edge | Edges@1] ->
            Reference = webql@compiler@context:next_edge(Context),
            gleam@result:'try'(
                webql@compiler@resolver@resolve_edge:resolve(
                    Environment,
                    Context,
                    Edge,
                    Reference
                ),
                fun(Edge@1) ->
                    Context@1 = webql@compiler@resolver@register_edge:register(
                        Context,
                        Edge@1
                    ),
                    gleam@result:'try'(
                        resolve_edges(Environment, Context@1, Edges@1),
                        fun(_use0) ->
                            {Edges@2, Context@2} = _use0,
                            {ok, {[Edge@1 | Edges@2], Context@2}}
                        end
                    )
                end
            );

        [] ->
            {ok, {[], Context}}
    end.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 103).
-spec resolve_returns(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    list(webql@compiler@parser@ast:return())
) -> {ok,
        {list(webql@compiler@resolver@hir:return()),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_returns(Environment, Context, Returns) ->
    case Returns of
        [Return | Rest] ->
            Reference = webql@compiler@context:next_return(Context),
            gleam@result:'try'(
                webql@compiler@resolver@resolve_return:resolve(
                    Environment,
                    Context,
                    Return,
                    Reference
                ),
                fun(Return@1) ->
                    Context@1 = webql@compiler@resolver@register_return:register(
                        Context,
                        Return@1
                    ),
                    gleam@result:'try'(
                        resolve_returns(Environment, Context@1, Rest),
                        fun(_use0) ->
                            {Rest@1, Context@2} = _use0,
                            {ok, {[Return@1 | Rest@1], Context@2}}
                        end
                    )
                end
            );

        [] ->
            {ok, {[], Context}}
    end.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 73).
-spec resolve_parameters(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    list(webql@compiler@parser@ast:parameter())
) -> {ok,
        {list(webql@compiler@resolver@hir:parameter()),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_parameters(Environment, Context, Parameters) ->
    case Parameters of
        [Parameter | Rest] ->
            Reference = webql@compiler@context:next_parameter(Context),
            gleam@result:'try'(
                webql@compiler@resolver@resolve_parameter:resolve(
                    Environment,
                    Context,
                    Parameter,
                    Reference
                ),
                fun(Parameter@1) ->
                    Context@1 = webql@compiler@resolver@register_parameter:register(
                        Context,
                        Parameter@1
                    ),
                    gleam@result:'try'(
                        resolve_parameters(Environment, Context@1, Rest),
                        fun(_use0) ->
                            {Rest@1, Context@2} = _use0,
                            {ok, {[Parameter@1 | Rest@1], Context@2}}
                        end
                    )
                end
            );

        [] ->
            {ok, {[], Context}}
    end.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 165).
-spec resolve_nodes(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    list(webql@compiler@parser@ast:node_())
) -> {ok,
        {list(webql@compiler@resolver@hir:node_()),
            webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_nodes(Environment, Context, Nodes) ->
    case Nodes of
        [{node, _, _, _} = Node | Nodes@1] ->
            gleam@result:'try'(
                webql@compiler@resolver@resolve_node:resolve(
                    Environment,
                    Context,
                    Node,
                    fun resolve/3
                ),
                fun(_use0) ->
                    {Node@1, Context@1, _} = _use0,
                    gleam@result:'try'(
                        resolve_nodes(Environment, Context@1, Nodes@1),
                        fun(_use0@1) ->
                            {Nodes@2, Context@2} = _use0@1,
                            {ok, {[Node@1 | Nodes@2], Context@2}}
                        end
                    )
                end
            );

        [{supernode, _, _, _} | Nodes@3] ->
            resolve_nodes(Environment, Context, Nodes@3);

        [] ->
            {ok, {[], Context}}
    end.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 133).
-spec resolve_supernodes(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    list(webql@compiler@parser@ast:node_())
) -> {ok,
        {list(webql@compiler@resolver@hir:node_()),
            webql@compiler@context:context(),
            webql@compiler@environment:environment()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_supernodes(Environment, Context, Nodes) ->
    case Nodes of
        [{supernode, _, _, _} = Supernode | Nodes@1] ->
            gleam@result:'try'(
                webql@compiler@resolver@resolve_node:resolve(
                    Environment,
                    Context,
                    Supernode,
                    fun resolve/3
                ),
                fun(_use0) ->
                    {Supernode@1, Context@1, Environment@1} = _use0,
                    gleam@result:'try'(
                        resolve_supernodes(Environment@1, Context@1, Nodes@1),
                        fun(_use0@1) ->
                            {Nodes@2, Context@2, Environment@2} = _use0@1,
                            {ok,
                                {[Supernode@1 | Nodes@2],
                                    Context@2,
                                    Environment@2}}
                        end
                    )
                end
            );

        [{node, _, _, _} | Nodes@3] ->
            resolve_supernodes(Environment, Context, Nodes@3);

        [] ->
            {ok, {[], Context, Environment}}
    end.

-file("src/webql/compiler/resolver/resolve_graph.gleam", 32).
-spec resolve_body(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:graph()
) -> {ok,
        {webql@compiler@resolver@hir:graph(),
            webql@compiler@context:context(),
            webql@compiler@environment:environment()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve_body(Environment, Context, Graph) ->
    {graph, Parameters, Returns, Nodes, Edges, Span} = Graph,
    gleam@result:'try'(
        resolve_parameters(Environment, Context, Parameters),
        fun(_use0) ->
            {Parameters@1, Context@1} = _use0,
            gleam@result:'try'(
                resolve_returns(Environment, Context@1, Returns),
                fun(_use0@1) ->
                    {Returns@1, Context@2} = _use0@1,
                    gleam@result:'try'(
                        resolve_supernodes(Environment, Context@2, Nodes),
                        fun(_use0@2) ->
                            {Supernodes, Context@3, Environment@1} = _use0@2,
                            gleam@result:'try'(
                                resolve_nodes(Environment@1, Context@3, Nodes),
                                fun(_use0@3) ->
                                    {Nodes@1, Context@4} = _use0@3,
                                    gleam@result:'try'(
                                        resolve_edges(
                                            Environment@1,
                                            Context@4,
                                            Edges
                                        ),
                                        fun(_use0@4) ->
                                            {Edges@1, Context@5} = _use0@4,
                                            Nodes@2 = lists:append(
                                                Supernodes,
                                                Nodes@1
                                            ),
                                            {ok,
                                                {{graph,
                                                        Parameters@1,
                                                        Returns@1,
                                                        Nodes@2,
                                                        Edges@1,
                                                        Span},
                                                    Context@5,
                                                    Environment@1}}
                                        end
                                    )
                                end
                            )
                        end
                    )
                end
            )
        end
    ).

-file("src/webql/compiler/resolver/resolve_graph.gleam", 17).
?DOC(" Resolves a graph body and its nested declarations.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:graph()
) -> {ok,
        {webql@compiler@resolver@hir:graph(), webql@compiler@context:context()}} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Graph) ->
    gleam@result:'try'(
        resolve_body(Environment, Context, Graph),
        fun(_use0) ->
            {Graph@1, Context@1, _} = _use0,
            {ok, {Graph@1, Context@1}}
        end
    ).
