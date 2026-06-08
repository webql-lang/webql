-module(webql@runner@run_step).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner/run_step.gleam").
-export([run/5]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/runner/run_step.gleam", 55).
-spec run_inline(
    gleam@dynamic:dynamic_(),
    webql@assembler@plan:plan(GRX),
    webql@engine:engine(GRX, webql@memory:memory(GRZ), GSB),
    webql@memory:memory(GRZ),
    fun((webql@assembler@plan:plan(GRX), webql@memory:memory(GRZ), webql@engine:engine(GRX, webql@memory:memory(GRZ), GSB), gleam@dynamic:dynamic_()) -> GRX)
) -> {ok, GRX} | {error, webql@runner@diagnostic:diagnostic()}.
run_inline(Inputs, Plan, Engine, Memory, Run_plan) ->
    Results = Run_plan(Plan, (erlang:element(2, Memory))(), Engine, Inputs),
    {ok,
        (erlang:element(4, Engine))(
            Results,
            fun(Memory@1) ->
                case webql@runner@run:get_returns(
                    Memory@1,
                    erlang:element(2, Plan)
                ) of
                    {ok, Returns} ->
                        {ok, Returns};

                    {error, Message} ->
                        {error, {diagnostic, {missing_return, Message}}}
                end
            end
        )}.

-file("src/webql/runner/run_step.gleam", 25).
-spec run_step(
    webql@assembler@plan:step(GRM),
    gleam@dynamic:dynamic_(),
    webql@engine:engine(GRM, webql@memory:memory(GRO), GRQ),
    webql@memory:memory(GRO),
    fun((webql@assembler@plan:plan(GRM), webql@memory:memory(GRO), webql@engine:engine(GRM, webql@memory:memory(GRO), GRQ), gleam@dynamic:dynamic_()) -> GRM)
) -> {ok, GRM} | {error, webql@runner@diagnostic:diagnostic()}.
run_step(Step, Inputs, Engine, Memory, Run_plan) ->
    gleam@result:'try'(case erlang:element(3, Step) of
            {node, Resolver} ->
                {ok, (erlang:element(2, Resolver))(Inputs)};

            {supernode, Plan} ->
                run_inline(Inputs, Plan, Engine, Memory, Run_plan)
        end, fun(Results) ->
            {ok,
                (erlang:element(8, Engine))(
                    Results,
                    fun(Result) -> case Result of
                            {ok, Outputs} ->
                                webql@runner@run:add_outputs(
                                    Memory,
                                    erlang:element(2, Step),
                                    Outputs
                                );

                            {error, Message} ->
                                {error,
                                    {diagnostic,
                                        {runtime_error,
                                            erlang:element(2, Step),
                                            Message}}}
                        end end
                )}
        end).

-file("src/webql/runner/run_step.gleam", 10).
?DOC(" Runs a step in a batch.\n").
-spec run(
    webql@assembler@plan:step(GRB),
    list(webql@assembler@plan:edge()),
    webql@engine:engine(GRB, webql@memory:memory(GRE), GRG),
    webql@memory:memory(GRE),
    fun((webql@assembler@plan:plan(GRB), webql@memory:memory(GRE), webql@engine:engine(GRB, webql@memory:memory(GRE), GRG), gleam@dynamic:dynamic_()) -> GRB)
) -> GRB.
run(Step, Edges, Engine, Memory, Run_plan) ->
    (erlang:element(7, Engine))(
        fun() ->
            gleam@result:'try'(
                webql@runner@run:get_inputs(
                    Memory,
                    erlang:element(2, Step),
                    Edges
                ),
                fun(Inputs) ->
                    run_step(Step, Inputs, Engine, Memory, Run_plan)
                end
            )
        end
    ).
