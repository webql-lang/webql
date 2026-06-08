-module(webql@compiler@resolver@register_return).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/register_return.gleam").
-export([register/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/register_return.gleam", 5).
?DOC(" Registers a return.\n").
-spec register(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:return()
) -> webql@compiler@context:context().
register(Context, Return) ->
    _pipe = Context,
    _pipe@1 = webql@compiler@context:add_return(
        _pipe,
        erlang:element(2, Return)
    ),
    webql@compiler@context:add_input(
        _pipe@1,
        [erlang:element(2, Return)],
        erlang:element(3, erlang:element(3, Return))
    ).
