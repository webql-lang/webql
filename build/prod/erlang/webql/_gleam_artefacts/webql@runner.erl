-module(webql@runner).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner.gleam").
-export([new/1, run/4]).
-export_type([runner/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque runner(GYM) :: {runner, webql@assembler@plan:plan(GYM)}.

-file("src/webql/runner.gleam", 12).
?DOC(" Creates a new runner instance from an executable plan.\n").
-spec new(webql@assembler@plan:plan(GYN)) -> runner(GYN).
new(Plan) ->
    {runner, Plan}.

-file("src/webql/runner.gleam", 17).
?DOC(" Runs an executable plan.\n").
-spec run(
    runner(GYQ),
    webql@memory:memory(GYS),
    webql@engine:engine(GYQ, webql@memory:memory(GYS), any()),
    gleam@dynamic:dynamic_()
) -> GYQ.
run(Runner, Memory, Engine, Parameters) ->
    webql@runner@run_plan:run(
        erlang:element(2, Runner),
        Memory,
        Engine,
        Parameters
    ).
