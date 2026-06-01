-module(webql@assembler@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {linker_diagnostic,
        webql@assembler@linker@diagnostic:diagnostic_kind()} |
    {scheduler_diagnostic,
        webql@assembler@scheduler@diagnostic:diagnostic_kind()}.

-type diagnostic() :: {diagnostic, diagnostic_kind()}.


