-module(webql@interpreter@interpret_batch).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/interpreter/interpret_batch.gleam").
-export([interpret/5]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/interpreter/interpret_batch.gleam", 8).
?DOC(" Runs the next batch in a plan.\n").
-spec interpret(
    list(webql@assembler@plan:step(GRY)),
    list(webql@assembler@plan:edge()),
    webql@engine:engine(GRY, webql@memory:memory(GSC), GSE),
    webql@memory:memory(GSC),
    fun((webql@assembler@plan:plan(GRY), webql@memory:memory(GSC), webql@engine:engine(GRY, webql@memory:memory(GSC), GSE), gleam@dynamic:dynamic_()) -> GRY)
) -> GRY.
interpret(Batch, Edges, Engine, Memory, Interpret_plan) ->
    Steps = (erlang:element(5, Engine))(fun() -> _pipe = Batch,
            _pipe@1 = gleam@list:map(
                _pipe,
                fun(Step) ->
                    webql@interpreter@interpret_step:interpret(
                        Step,
                        Edges,
                        Engine,
                        Memory,
                        Interpret_plan
                    )
                end
            ),
            {ok, _pipe@1} end),
    (erlang:element(6, Engine))(Memory, Steps, erlang:element(6, Memory)).
