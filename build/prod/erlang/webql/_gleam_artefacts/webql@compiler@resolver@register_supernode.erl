-module(webql@compiler@resolver@register_supernode).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/register_supernode.gleam").
-export([register/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/register_supernode.gleam", 5).
?DOC(" Registers a supernode.\n").
-spec register(
    webql@compiler@context:context(),
    binary(),
    webql@compiler@reference:supernode(),
    webql@compiler@context:context()
) -> webql@compiler@context:context().
register(Context, Name, Reference, Sub_context) ->
    _pipe = Context,
    _pipe@1 = webql@compiler@context:add_supernode(_pipe, Name),
    webql@compiler@context:add_context(_pipe@1, Reference, Sub_context).
