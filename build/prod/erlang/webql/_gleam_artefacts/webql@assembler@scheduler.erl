-module(webql@assembler@scheduler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/scheduler.gleam").
-export([new/1, schedule/1]).
-export_type([scheduler/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque scheduler(EAD) :: {scheduler,
        webql@assembler@linker@program:program(EAD)}.

-file("src/webql/assembler/scheduler.gleam", 11).
?DOC(" Creates a new scheduler instance from a linker program.\n").
-spec new(webql@assembler@linker@program:program(EAE)) -> scheduler(EAE).
new(Plan) ->
    {scheduler, Plan}.

-file("src/webql/assembler/scheduler.gleam", 16).
?DOC(" Schedules a linker program.\n").
-spec schedule(scheduler(EAH)) -> {ok, webql@assembler@plan:plan(EAH)} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule(Scheduler) ->
    webql@assembler@scheduler@schedule_plan:schedule(
        erlang:element(2, Scheduler)
    ).
