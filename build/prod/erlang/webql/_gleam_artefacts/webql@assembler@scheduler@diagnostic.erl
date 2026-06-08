-module(webql@assembler@scheduler@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/scheduler/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {cycle_detected, list(binary())} | invalid_plan.

-type diagnostic() :: {diagnostic, diagnostic_kind()}.


