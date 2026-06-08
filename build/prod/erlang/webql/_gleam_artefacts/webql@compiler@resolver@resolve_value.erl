-module(webql@compiler@resolver@resolve_value).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_value.gleam").
-export([resolve/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_value.gleam", 5).
?DOC(" Resolves a parser value into a resolver value.\n").
-spec resolve(webql@compiler@parser@ast:value()) -> webql@compiler@resolver@hir:value().
resolve(Value) ->
    case Value of
        {int, Name, Value@1, Span} ->
            {int, Name, Value@1, Span};

        {float, Name@1, Value@2, Span@1} ->
            {float, Name@1, Value@2, Span@1};

        {string, Name@2, Value@3, Span@2} ->
            {string, Name@2, Value@3, Span@2}
    end.
