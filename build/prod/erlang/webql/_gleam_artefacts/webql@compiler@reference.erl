-module(webql@compiler@reference).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/reference.gleam").
-export_type([node_/0, supernode/0, edge/0, document/0, operation/0, parameter/0, return/0, input/0, output/0, port_/0]).

-type node_() :: {node, integer()}.

-type supernode() :: {supernode, integer()}.

-type edge() :: {edge, integer()}.

-type document() :: {document, integer()}.

-type operation() :: {operation, integer()}.

-type parameter() :: {parameter, integer()}.

-type return() :: {return, integer()}.

-type input() :: {input, integer()}.

-type output() :: {output, integer()}.

-type port_() :: {port, integer()}.


