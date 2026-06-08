-module(webql@compiler@resolver@resolve_target).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_target.gleam").
-export([resolve/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_target.gleam", 7).
?DOC(" Resolves an edge target.\n").
-spec resolve(
    webql@compiler@context:context(),
    webql@compiler@parser@ast:target()
) -> {ok, webql@compiler@resolver@hir:target()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Context, Target) ->
    {input, Path, Span} = Target,
    case webql@compiler@context:get_input(Context, Path) of
        {ok, {Reference, _}} ->
            {ok, {input, Path, Reference, Span}};

        {error, _} ->
            {error, {diagnostic, {unknown_input, Path}, Span}}
    end.
