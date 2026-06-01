-module(webql@compiler@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: {lexer_diagnostic,
        webql@compiler@lexer@diagnostic:diagnostic_kind()} |
    {parser_diagnostic, webql@compiler@parser@diagnostic:diagnostic_kind()} |
    {resolver_diagnostic, webql@compiler@resolver@diagnostic:diagnostic_kind()} |
    {typechecker_diagnostic,
        webql@compiler@typechecker@diagnostic:diagnostic_kind()}.

-type diagnostic() :: {diagnostic,
        diagnostic_kind(),
        webql@compiler@source:span()}.


