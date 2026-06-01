-module(webql@interpreter@interpret_step).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/interpreter/interpret_step.gleam").
-export([interpret/5]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/interpreter/interpret_step.gleam", 56).
-spec interpret_inline(
    gleam@dynamic:dynamic_(),
    webql@assembler@plan:plan(GOX),
    webql@engine:engine(GOX, webql@memory:memory(GOZ), GPB),
    webql@memory:memory(GOZ),
    fun((webql@assembler@plan:plan(GOX), webql@memory:memory(GOZ), webql@engine:engine(GOX, webql@memory:memory(GOZ), GPB), gleam@dynamic:dynamic_()) -> GOX)
) -> {ok, GOX} | {error, any()}.
interpret_inline(Inputs, Plan, Engine, Memory, Interpret_plan) ->
    Results = Interpret_plan(
        Plan,
        (erlang:element(2, Memory))(),
        Engine,
        Inputs
    ),
    {ok,
        (erlang:element(4, Engine))(
            Results,
            fun(Memory@1) ->
                case webql@interpreter@progress:get_returns(
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

-file("src/webql/interpreter/interpret_step.gleam", 25).
-spec interpret_step(
    webql@assembler@plan:step(GOM),
    gleam@dynamic:dynamic_(),
    webql@engine:engine(GOM, webql@memory:memory(GOO), GOQ),
    webql@memory:memory(GOO),
    fun((webql@assembler@plan:plan(GOM), webql@memory:memory(GOO), webql@engine:engine(GOM, webql@memory:memory(GOO), GOQ), gleam@dynamic:dynamic_()) -> GOM)
) -> {ok, GOM} | {error, any()}.
interpret_step(Step, Inputs, Engine, Memory, Interpret_plan) ->
    gleam@result:'try'(case erlang:element(3, Step) of
            {node, Resolver} ->
                {ok, (erlang:element(2, Resolver))(Inputs)};

            {supernode, Plan} ->
                interpret_inline(Inputs, Plan, Engine, Memory, Interpret_plan)
        end, fun(Results) ->
            {ok,
                (erlang:element(8, Engine))(
                    Results,
                    fun(Result) -> case Result of
                            {ok, Outputs} ->
                                webql@interpreter@progress:add_outputs(
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

-file("src/webql/interpreter/interpret_step.gleam", 10).
?DOC(" Runs a step in a batch.\n").
-spec interpret(
    webql@assembler@plan:step(GOB),
    list(webql@assembler@plan:edge()),
    webql@engine:engine(GOB, webql@memory:memory(GOE), GOG),
    webql@memory:memory(GOE),
    fun((webql@assembler@plan:plan(GOB), webql@memory:memory(GOE), webql@engine:engine(GOB, webql@memory:memory(GOE), GOG), gleam@dynamic:dynamic_()) -> GOB)
) -> GOB.
interpret(Step, Edges, Engine, Memory, Interpret_plan) ->
    (erlang:element(7, Engine))(
        fun() ->
            gleam@result:'try'(
                webql@interpreter@progress:get_inputs(
                    Memory,
                    erlang:element(2, Step),
                    Edges
                ),
                fun(Inputs) ->
                    interpret_step(Step, Inputs, Engine, Memory, Interpret_plan)
                end
            )
        end
    ).
