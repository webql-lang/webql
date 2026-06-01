-module(webql@engine@basic).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/engine/basic.gleam").
-export([handle_finish_step/2, handle_start_step/1, handle_finish_batch/3, handle_start_batch/1, handle_finish_plan/2, handle_start_plan/1, handle_run/1, new/0]).
-export_type([basic/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type basic(GZI) :: any() | {gleam_phantom, GZI}.

-file("src/webql/engine/basic.gleam", 75).
-spec handle_finish_step(
    basic(HBA),
    fun(({ok, gleam@dynamic:dynamic_()} | {error, gleam@dynamic:dynamic_()}) -> {ok,
            webql@memory:memory(HBA)} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(HBA).
handle_finish_step(Task, Next) ->
    basic_ffi:handle_finish_step(Task, Next).

-file("src/webql/engine/basic.gleam", 69).
-spec handle_start_step(
    fun(() -> {ok, basic(HAV)} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(HAV).
handle_start_step(Next) ->
    basic_ffi:handle_start_step(Next).

-file("src/webql/engine/basic.gleam", 60).
-spec handle_finish_batch(
    webql@memory:memory(HAO),
    basic(HAO),
    fun((webql@memory:memory(HAO), webql@memory:memory(HAO)) -> webql@memory:memory(HAO))
) -> basic(HAO).
handle_finish_batch(Initial, Task, Merge) ->
    basic_ffi:handle_finish_batch(Initial, Task, Merge).

-file("src/webql/engine/basic.gleam", 54).
-spec handle_start_batch(
    fun(() -> {ok, list(basic(HAI))} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(HAI).
handle_start_batch(Next) ->
    basic_ffi:handle_start_batch(Next).

-file("src/webql/engine/basic.gleam", 46).
-spec handle_finish_plan(
    basic(HAC),
    fun((webql@memory:memory(HAC)) -> {ok, gleam@dynamic:dynamic_()} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(HAC).
handle_finish_plan(Task, Next) ->
    basic_ffi:handle_finish_plan(Task, Next).

-file("src/webql/engine/basic.gleam", 33).
-spec handle_start_plan(
    fun(() -> {ok,
            {webql@memory:memory(GZU),
                list(fun((webql@memory:memory(GZU)) -> basic(GZU)))}} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(GZU).
handle_start_plan(Next) ->
    basic_ffi:handle_start_plan(Next).

-file("src/webql/engine/basic.gleam", 27).
-spec handle_run(
    fun(() -> {ok, basic(GZP)} |
        {error, webql@interpreter@diagnostic:diagnostic()})
) -> basic(GZP).
handle_run(Next) ->
    basic_ffi:handle_run(Next).

-file("src/webql/engine/basic.gleam", 9).
?DOC(" Creates a new basic engine.\n").
-spec new() -> webql@engine:engine(basic(GZJ), webql@memory:memory(GZJ), webql@interpreter@diagnostic:diagnostic()).
new() ->
    {engine,
        fun basic_ffi:handle_run/1,
        fun basic_ffi:handle_start_plan/1,
        fun basic_ffi:handle_finish_plan/2,
        fun basic_ffi:handle_start_batch/1,
        fun basic_ffi:handle_finish_batch/3,
        fun basic_ffi:handle_start_step/1,
        fun basic_ffi:handle_finish_step/2}.
