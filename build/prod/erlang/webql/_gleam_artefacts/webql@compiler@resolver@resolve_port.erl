-module(webql@compiler@resolver@resolve_port).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/resolve_port.gleam").
-export([resolve/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/resolve_port.gleam", 7).
?DOC(" Resolves ports in a field.\n").
-spec resolve(
    webql@compiler@environment:environment(),
    webql@compiler@parser@ast:port_()
) -> {ok, webql@compiler@resolver@hir:port_()} |
    {error, webql@compiler@resolver@diagnostic:diagnostic()}.
resolve(Environment, Port) ->
    case webql@compiler@environment:get_port(
        Environment,
        erlang:element(2, Port)
    ) of
        {ok, Reference} ->
            {ok,
                {port,
                    erlang:element(2, Port),
                    Reference,
                    erlang:element(3, Port)}};

        {error, _} ->
            {error,
                {diagnostic,
                    {unknown_port, erlang:element(2, Port)},
                    erlang:element(3, Port)}}
    end.
