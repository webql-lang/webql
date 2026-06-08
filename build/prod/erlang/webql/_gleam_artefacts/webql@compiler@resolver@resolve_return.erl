-module(webql@compiler@resolver@resolve_return).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_return.gleam").
-export([resolve/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_return.gleam", 12).
?DOC(" Resolves an output field.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:return(),
    webql@compiler@reference:return()
) -> {ok, webql@compiler@resolver@hir:return()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Field, Reference) ->
    {return, Name, Port, Span} = Field,
    gleam@bool:guard(
        gleam@result:is_ok(webql@compiler@context:get_return(Context, Name)),
        {error, {diagnostic, {duplicate_return, Name}, Span}},
        fun() ->
            gleam@result:'try'(
                webql@compiler@resolver@resolve_port:resolve(Environment, Port),
                fun(Port@1) -> {ok, {return, Name, Port@1, Reference, Span}} end
            )
        end
    ).
