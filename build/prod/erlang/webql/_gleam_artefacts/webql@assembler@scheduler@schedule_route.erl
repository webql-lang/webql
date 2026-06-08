-module(webql@assembler@scheduler@schedule_route).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/scheduler/schedule_route.gleam").
-export([schedule/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/assembler/scheduler/schedule_route.gleam", 28).
-spec scheduled_dependencies(
    gleam@option:option(gleam@dict:dict(binary(), gleam@set:set(binary()))),
    gleam@dict:dict(binary(), gleam@set:set(binary()))
) -> gleam@dict:dict(binary(), gleam@set:set(binary())).
scheduled_dependencies(Scheduled, Dependencies) ->
    case Scheduled of
        {some, Dependencies@1} ->
            Dependencies@1;

        none ->
            Dependencies
    end.

-file("src/webql/assembler/scheduler/schedule_route.gleam", 53).
-spec schedule_dependency(
    gleam@dict:dict(binary(), gleam@set:set(binary())),
    binary(),
    binary()
) -> gleam@dict:dict(binary(), gleam@set:set(binary())).
schedule_dependency(Dependencies, Consumer, Producer) ->
    gleam@dict:upsert(Dependencies, Consumer, fun(Upstream) -> case Upstream of
                {some, Upstream@1} ->
                    gleam@set:insert(Upstream@1, Producer);

                none ->
                    gleam@set:from_list([Producer])
            end end).

-file("src/webql/assembler/scheduler/schedule_route.gleam", 38).
-spec schedule_dependencies(
    gleam@dict:dict(binary(), gleam@set:set(binary())),
    binary(),
    binary()
) -> gleam@option:option(gleam@dict:dict(binary(), gleam@set:set(binary()))).
schedule_dependencies(Dependencies, Consumer, Producer) ->
    case {gleam_stdlib:map_get(Dependencies, Consumer),
        gleam_stdlib:map_get(Dependencies, Producer)} of
        {{ok, _}, {ok, _}} ->
            gleam@bool:guard(
                Producer =:= Consumer,
                none,
                fun() ->
                    {some,
                        schedule_dependency(Dependencies, Consumer, Producer)}
                end
            );

        {_, _} ->
            none
    end.

-file("src/webql/assembler/scheduler/schedule_route.gleam", 8).
?DOC(" Adds a scheduled dependency for an edge.\n").
-spec schedule(
    gleam@dict:dict(binary(), gleam@set:set(binary())),
    webql@assembler@linker@program:edge()
) -> gleam@dict:dict(binary(), gleam@set:set(binary())).
schedule(Dependencies, Edge) ->
    Scheduled = case Edge of
        {edge, {output, [Producer | _]}, {input, [Consumer | _]}} ->
            schedule_dependencies(Dependencies, Consumer, Producer);

        _ ->
            none
    end,
    scheduled_dependencies(Scheduled, Dependencies).
