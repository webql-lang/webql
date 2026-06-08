-module(webql@runner@run_plan).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner/run_plan.gleam").
-export([run/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/runner/run_plan.gleam", 32).
-spec run_plan(
    webql@assembler@plan:plan(GWN),
    webql@memory:memory(GWP),
    webql@engine:engine(GWN, webql@memory:memory(GWP), any()),
    gleam@dynamic:dynamic_()
) -> GWN.
run_plan(Plan, Memory, Engine, Parameters) ->
    {plan, Edges, Batches} = Plan,
    (erlang:element(3, Engine))(
        fun() ->
            gleam@result:'try'(
                webql@runner@run:add_parameters(Memory, Parameters),
                fun(Memory@1) ->
                    {ok,
                        {Memory@1,
                            gleam@list:map(
                                Batches,
                                fun(Batch) ->
                                    fun(Memory@2) ->
                                        {batch, Steps} = Batch,
                                        webql@runner@run_batch:run(
                                            Steps,
                                            Edges,
                                            Engine,
                                            Memory@2,
                                            fun run_plan/4
                                        )
                                    end
                                end
                            )}}
                end
            )
        end
    ).

-file("src/webql/runner/run_plan.gleam", 12).
?DOC(" Runs an executable plan.\n").
-spec run(
    webql@assembler@plan:plan(GWE),
    webql@memory:memory(GWG),
    webql@engine:engine(GWE, webql@memory:memory(GWG), any()),
    gleam@dynamic:dynamic_()
) -> GWE.
run(Plan, Memory, Engine, Parameters) ->
    Result = run_plan(Plan, Memory, Engine, Parameters),
    (erlang:element(4, Engine))(
        Result,
        fun(Memory@1) ->
            case webql@runner@run:get_returns(Memory@1, erlang:element(2, Plan)) of
                {ok, Returns} ->
                    {ok, Returns};

                {error, Message} ->
                    {error, {diagnostic, {missing_return, Message}}}
            end
        end
    ).
