-module(webql@compiler@typechecker@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/typechecker/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {unknown_supernode,
        webql@compiler@reference:supernode()} |
    {unknown_input, list(binary())} |
    {unknown_output, list(binary())} |
    {type_mismatch,
        webql@compiler@reference:port_(),
        webql@compiler@reference:port_()}.

-type diagnostic() :: {diagnostic,
        diagnostic_kind(),
        webql@compiler@source:span()}.


