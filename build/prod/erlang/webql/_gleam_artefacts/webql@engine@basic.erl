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

-type basic(HCE) :: any() | {gleam_phantom, HCE}.

-file("src/webql/engine/basic.gleam", 75).
-spec handle_finish_step(
    basic(HDW),
    fun(({ok, gleam@dynamic:dynamic_()} | {error, gleam@dynamic:dynamic_()}) -> {ok,
            webql@memory:memory(HDW)} |
        {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HDW).
handle_finish_step(Task, Next) ->
    basic_ffi:handle_finish_step(Task, Next).

-file("src/webql/engine/basic.gleam", 69).
-spec handle_start_step(
    fun(() -> {ok, basic(HDR)} | {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HDR).
handle_start_step(Next) ->
    basic_ffi:handle_start_step(Next).

-file("src/webql/engine/basic.gleam", 60).
-spec handle_finish_batch(
    webql@memory:memory(HDK),
    basic(HDK),
    fun((webql@memory:memory(HDK), webql@memory:memory(HDK)) -> webql@memory:memory(HDK))
) -> basic(HDK).
handle_finish_batch(Initial, Task, Merge) ->
    basic_ffi:handle_finish_batch(Initial, Task, Merge).

-file("src/webql/engine/basic.gleam", 54).
-spec handle_start_batch(
    fun(() -> {ok, list(basic(HDE))} |
        {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HDE).
handle_start_batch(Next) ->
    basic_ffi:handle_start_batch(Next).

-file("src/webql/engine/basic.gleam", 46).
-spec handle_finish_plan(
    basic(HCY),
    fun((webql@memory:memory(HCY)) -> {ok, gleam@dynamic:dynamic_()} |
        {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HCY).
handle_finish_plan(Task, Next) ->
    basic_ffi:handle_finish_plan(Task, Next).

-file("src/webql/engine/basic.gleam", 33).
-spec handle_start_plan(
    fun(() -> {ok,
            {webql@memory:memory(HCQ),
                list(fun((webql@memory:memory(HCQ)) -> basic(HCQ)))}} |
        {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HCQ).
handle_start_plan(Next) ->
    basic_ffi:handle_start_plan(Next).

-file("src/webql/engine/basic.gleam", 27).
-spec handle_run(
    fun(() -> {ok, basic(HCL)} | {error, webql@runner@diagnostic:diagnostic()})
) -> basic(HCL).
handle_run(Next) ->
    basic_ffi:handle_run(Next).

-file("src/webql/engine/basic.gleam", 9).
?DOC(" Creates a new basic engine.\n").
-spec new() -> webql@engine:engine(basic(HCF), webql@memory:memory(HCF), webql@runner@diagnostic:diagnostic()).
new() ->
    {engine,
        fun basic_ffi:handle_run/1,
        fun basic_ffi:handle_start_plan/1,
        fun basic_ffi:handle_finish_plan/2,
        fun basic_ffi:handle_start_batch/1,
        fun basic_ffi:handle_finish_batch/3,
        fun basic_ffi:handle_start_step/1,
        fun basic_ffi:handle_finish_step/2}.
