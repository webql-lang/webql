-module(webql@compiler@parser@parse_port).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/parser/parse_port.gleam").
-export([parse/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/parser/parse_port.gleam", 15).
?DOC(
    " Parses a port annotation in a parameter.\n"
    "\n"
    " ## Examples\n"
    "\n"
    "     Int\n"
    "     Float\n"
    "     String\n"
).
-spec parse(binary(), list(webql@compiler@lexer@token:token())) -> {ok,
        {webql@compiler@parser@ast:port_(),
            webql@compiler@source:span(),
            list(webql@compiler@lexer@token:token())}} |
    {error, webql@compiler@parser@diagnostic:diagnostic()}.
parse(Source, Tokens) ->
    case Tokens of
        [{token, upper_identifier, Span} | Rest] ->
            Name = webql@compiler@source:slice(Source, Span),
            {ok, {{port, Name, Span}, Span, Rest}};

        _ ->
            gleam@result:'try'(
                webql@compiler@parser@parse_nonstarter:parse(Source, Tokens),
                fun(Tokens@1) -> parse(Source, Tokens@1) end
            )
    end.
