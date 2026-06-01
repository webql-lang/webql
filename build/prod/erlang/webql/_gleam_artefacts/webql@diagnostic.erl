-module(webql@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {assembler_diagnostic,
        webql@assembler@diagnostic:diagnostic_kind()} |
    {compiler_diagnostic, webql@compiler@diagnostic:diagnostic_kind()} |
    {interpreter_diagnostic, webql@interpreter@diagnostic:diagnostic_kind()}.

-type diagnostic() :: {diagnostic, diagnostic_kind()}.


