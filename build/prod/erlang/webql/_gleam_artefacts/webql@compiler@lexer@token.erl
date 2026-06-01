-module(webql@compiler@lexer@token).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lexer/token.gleam").
-export_type([token_kind/0, token/0]).

-type token_kind() :: name |
    int |
    float |
    string |
    comment_single |
    l_paren |
    r_paren |
    l_brace |
    r_brace |
    l_square |
    r_square |
    colon |
    comma |
    equal |
    r_arrow |
    dot |
    upper_identifier |
    lower_identifier |
    space |
    e_o_f |
    {diagnostic, webql@compiler@lexer@diagnostic:diagnostic_kind()}.

-type token() :: {token, token_kind(), webql@compiler@source:span()}.


