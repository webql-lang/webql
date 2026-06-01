-module(webql@compiler@parser@diagnostic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/diagnostic.gleam").
-export_type([diagnostic_kind/0, diagnostic/0]).

-type diagnostic_kind() :: unexpected_eof |
    {unexpected_token, webql@compiler@lexer@token:token_kind()}.

-type diagnostic() :: {diagnostic,
        diagnostic_kind(),
        webql@compiler@source:span()}.


