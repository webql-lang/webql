-module(webql@interpreter@interpret_plan).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/interpreter/interpret_plan.gleam").
-export([interpret/4]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/interpreter/interpret_plan.gleam", 32).
-spec interpret_plan(
    webql@assembler@plan:plan(GTJ),
    webql@memory:memory(GTL),
    webql@engine:engine(GTJ, webql@memory:memory(GTL), any()),
    gleam@dynamic:dynamic_()
) -> GTJ.
interpret_plan(Plan, Memory, Engine, Parameters) ->
    {plan, Edges, Batches} = Plan,
    (erlang:element(3, Engine))(
        fun() ->
            gleam@result:'try'(
                webql@interpreter@progress:add_parameters(Memory, Parameters),
                fun(Memory@1) ->
                    {ok,
                        {Memory@1,
                            gleam@list:map(
                                Batches,
                                fun(Batch) ->
                                    fun(Memory@2) ->
                                        {batch, Steps} = Batch,
                                        webql@interpreter@interpret_batch:interpret(
                                            Steps,
                                            Edges,
                                            Engine,
                                            Memory@2,
                                            fun interpret_plan/4
                                        )
                                    end
                                end
                            )}}
                end
            )
        end
    ).

-file("src/webql/interpreter/interpret_plan.gleam", 12).
?DOC(" Runs an executable plan.\n").
-spec interpret(
    webql@assembler@plan:plan(GTA),
    webql@memory:memory(GTC),
    webql@engine:engine(GTA, webql@memory:memory(GTC), any()),
    gleam@dynamic:dynamic_()
) -> GTA.
interpret(Plan, Memory, Engine, Parameters) ->
    Result = interpret_plan(Plan, Memory, Engine, Parameters),
    (erlang:element(4, Engine))(
        Result,
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
    ).
