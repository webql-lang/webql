-module(webql@assembler@linker@link_route).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/linker/link_route.gleam").
-export([link/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/assembler/linker/link_route.gleam", 33).
-spec link_constant(webql@graph:value()) -> gleam@dynamic:dynamic_().
link_constant(Value) ->
    case Value of
        {int, Value@1} ->
            gleam_stdlib:identity(Value@1);

        {float, Value@2} ->
            gleam_stdlib:identity(Value@2);

        {string, Value@3} ->
            gleam_stdlib:identity(Value@3)
    end.

-file("src/webql/assembler/linker/link_route.gleam", 7).
?DOC(" Links graph edges into scheduler program edges.\n").
-spec link(list(webql@graph:edge())) -> list(webql@assembler@linker@program:edge()).
link(Edges) ->
    gleam@list:map(Edges, fun(Edge) -> case Edge of
                {edge, {output, From}, {input, To}} ->
                    {edge, {output, From}, {input, To}};

                {edge, {literal, Value}, {input, To@1}} ->
                    {edge, {literal, link_constant(Value)}, {input, To@1}}
            end end).
