-module(webql@interpreter).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/interpreter.gleam").
-export([new/1, interpret/4]).
-export_type([interpreter/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque interpreter(GVF) :: {interpreter, webql@assembler@plan:plan(GVF)}.

-file("src/webql/interpreter.gleam", 12).
?DOC(" Creates a new interpreter instance from an executable plan.\n").
-spec new(webql@assembler@plan:plan(GVG)) -> interpreter(GVG).
new(Plan) ->
    {interpreter, Plan}.

-file("src/webql/interpreter.gleam", 17).
?DOC(" Runs an executable plan.\n").
-spec interpret(
    interpreter(GVJ),
    webql@memory:memory(GVL),
    webql@engine:engine(GVJ, webql@memory:memory(GVL), any()),
    gleam@dynamic:dynamic_()
) -> GVJ.
interpret(Interpreter, Memory, Engine, Parameters) ->
    webql@interpreter@interpret_plan:interpret(
        erlang:element(2, Interpreter),
        Memory,
        Engine,
        Parameters
    ).
