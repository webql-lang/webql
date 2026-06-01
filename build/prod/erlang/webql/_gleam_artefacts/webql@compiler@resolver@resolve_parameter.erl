-module(webql@compiler@resolver@resolve_parameter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_parameter.gleam").
-export([resolve/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_parameter.gleam", 12).
?DOC(" Resolves an input field.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@parser@ast:parameter(),
    webql@compiler@reference:parameter()
) -> {ok, webql@compiler@resolver@hir:parameter()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Context, Field, Reference) ->
    {parameter, Name, Port, Span} = Field,
    gleam@bool:guard(
        gleam@result:is_ok(webql@compiler@context:get_parameter(Context, Name)),
        {error, {diagnostic, {duplicate_parameter, Name}, Span}},
        fun() ->
            gleam@result:'try'(
                webql@compiler@resolver@resolve_port:resolve(Environment, Port),
                fun(Port@1) ->
                    {ok, {parameter, Name, Port@1, Reference, Span}}
                end
            )
        end
    ).
