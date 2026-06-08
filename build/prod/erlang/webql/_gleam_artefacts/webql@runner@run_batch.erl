-module(webql@runner@run_batch).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner/run_batch.gleam").
-export([run/5]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/runner/run_batch.gleam", 8).
?DOC(" Runs the next batch in a plan.\n").
-spec run(
    list(webql@assembler@plan:step(GVC)),
    list(webql@assembler@plan:edge()),
    webql@engine:engine(GVC, webql@memory:memory(GVG), GVI),
    webql@memory:memory(GVG),
    fun((webql@assembler@plan:plan(GVC), webql@memory:memory(GVG), webql@engine:engine(GVC, webql@memory:memory(GVG), GVI), gleam@dynamic:dynamic_()) -> GVC)
) -> GVC.
run(Batch, Edges, Engine, Memory, Run_plan) ->
    Steps = (erlang:element(5, Engine))(
        fun() ->
            {ok,
                gleam@list:map(
                    Batch,
                    fun(Step) ->
                        webql@runner@run_step:run(
                            Step,
                            Edges,
                            Engine,
                            Memory,
                            Run_plan
                        )
                    end
                )}
        end
    ),
    (erlang:element(6, Engine))(Memory, Steps, erlang:element(6, Memory)).
