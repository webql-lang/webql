-module(webql@compiler@resolver@register_parameter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/register_parameter.gleam").
-export([register/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/register_parameter.gleam", 5).
?DOC(" Registers a parameter.\n").
-spec register(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:parameter()
) -> webql@compiler@context:context().
register(Context, Parameter) ->
    _pipe = Context,
    _pipe@1 = webql@compiler@context:add_parameter(
        _pipe,
        erlang:element(2, Parameter)
    ),
    webql@compiler@context:add_output(
        _pipe@1,
        [erlang:element(2, Parameter)],
        erlang:element(3, erlang:element(3, Parameter))
    ).
