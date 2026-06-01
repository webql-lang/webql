-module(webql@graph).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/graph.gleam").
-export_type([graph/0, parameter/0, return/0, node_/0, edge/0, source/0, target/0, value/0]).

-type graph() :: {graph,
        list(parameter()),
        list(return()),
        list(node_()),
        list(edge())}.

-type parameter() :: {parameter, binary(), binary()}.

-type return() :: {return, binary(), binary()}.

-type node_() :: {supernode, binary(), graph()} | {node, binary(), binary()}.

-type edge() :: {edge, source(), target()}.

-type source() :: {output, list(binary())} | {literal, value()}.

-type target() :: {input, list(binary())}.

-type value() :: {int, integer()} | {float, float()} | {string, binary()}.


