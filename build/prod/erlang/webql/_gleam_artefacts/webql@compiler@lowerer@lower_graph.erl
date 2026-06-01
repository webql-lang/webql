-module(webql@compiler@lowerer@lower_graph).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_graph.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_graph.gleam", 35).
-spec lower_nodes(
    list(webql@compiler@resolver@hir:node_()),
    list({binary(), webql@graph:graph()})
) -> list(webql@graph:node_()).
lower_nodes(Nodes, Supernodes) ->
    case Nodes of
        [{supernode, _, _, _, _} | Nodes@1] ->
            lower_nodes(Nodes@1, Supernodes);

        [{node, Name, Node, _, _, _} | Nodes@2] ->
            Node@1 = webql@compiler@lowerer@lower_node:lower(
                Name,
                Node,
                Supernodes
            ),
            [Node@1 | lower_nodes(Nodes@2, Supernodes)];

        [] ->
            []
    end.

-file("src/webql/compiler/lowerer/lower_graph.gleam", 23).
-spec lower_supernodes(list(webql@compiler@resolver@hir:node_())) -> list({binary(),
    webql@graph:graph()}).
lower_supernodes(Nodes) ->
    case Nodes of
        [{supernode, Name, Graph, _, _} | Nodes@1] ->
            [{Name, lower(Graph)} | lower_supernodes(Nodes@1)];

        [{node, _, _, _, _, _} | Nodes@2] ->
            lower_supernodes(Nodes@2);

        [] ->
            []
    end.

-file("src/webql/compiler/lowerer/lower_graph.gleam", 10).
?DOC(" Lowers a resolved graph into IR.\n").
-spec lower(webql@compiler@resolver@hir:graph()) -> webql@graph:graph().
lower(Graph) ->
    Supernodes = lower_supernodes(erlang:element(4, Graph)),
    {graph,
        gleam@list:map(
            erlang:element(2, Graph),
            fun webql@compiler@lowerer@lower_parameter:lower/1
        ),
        gleam@list:map(
            erlang:element(3, Graph),
            fun webql@compiler@lowerer@lower_return:lower/1
        ),
        lower_nodes(erlang:element(4, Graph), Supernodes),
        gleam@list:map(
            erlang:element(5, Graph),
            fun webql@compiler@lowerer@lower_edge:lower/1
        )}.
