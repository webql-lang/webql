-module(webql@compiler@parser@ast).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/ast.gleam").
-export_type([document/0, graph/0, parameter/0, return/0, port_/0, node_/0, edge/0, target/0, source/0, value/0]).

-type document() :: {document, graph(), webql@compiler@source:span()}.

-type graph() :: {graph,
        list(parameter()),
        list(return()),
        list(node_()),
        list(edge()),
        webql@compiler@source:span()}.

-type parameter() :: {parameter,
        binary(),
        port_(),
        webql@compiler@source:span()}.

-type return() :: {return, binary(), port_(), webql@compiler@source:span()}.

-type port_() :: {port, binary(), webql@compiler@source:span()}.

-type node_() :: {supernode, binary(), graph(), webql@compiler@source:span()} |
    {node, binary(), binary(), webql@compiler@source:span()}.

-type edge() :: {edge, source(), target(), webql@compiler@source:span()}.

-type target() :: {input, list(binary()), webql@compiler@source:span()}.

-type source() :: {output, list(binary()), webql@compiler@source:span()} |
    {literal, value(), webql@compiler@source:span()}.

-type value() :: {int, binary(), integer(), webql@compiler@source:span()} |
    {float, binary(), float(), webql@compiler@source:span()} |
    {string, binary(), binary(), webql@compiler@source:span()}.


