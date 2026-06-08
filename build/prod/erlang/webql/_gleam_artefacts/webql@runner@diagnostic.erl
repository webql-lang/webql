-module(webql@runner@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {missing_step_input,
        binary(),
        gleam@dynamic:dynamic_()} |
    {missing_return, gleam@dynamic:dynamic_()} |
    {invalid_parameters, list(gleam@dynamic@decode:decode_error())} |
    {runtime_error, binary(), gleam@dynamic:dynamic_()} |
    {invalid_step_output, binary(), list(gleam@dynamic@decode:decode_error())}.

-type diagnostic() :: {diagnostic, diagnostic_kind()}.


