-module(webql@compiler@resolver@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {unknown_port, binary()} |
    {unknown_node, binary()} |
    {unknown_input, list(binary())} |
    {unknown_output, list(binary())} |
    {duplicate_return, binary()} |
    {duplicate_parameter, binary()} |
    {duplicate_supernode, binary()} |
    {duplicate_node, binary()} |
    {duplicate_edge_input, list(binary())}.

-type diagnostic() :: {diagnostic,
        diagnostic_kind(),
        webql@compiler@source:span()}.


