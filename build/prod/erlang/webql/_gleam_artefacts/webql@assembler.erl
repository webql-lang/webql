-module(webql@assembler).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler.gleam").
-export([new/1, assemble/2]).
-export_type([assembler/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque assembler(EAR) :: {assembler, webql@schema:schema(EAR)}.

-file("src/webql/assembler.gleam", 15).
?DOC(" Creates a new assembler instance from an executable plan.\n").
-spec new(webql@schema:schema(EAS)) -> assembler(EAS).
new(Schema) ->
    {assembler, Schema}.

-file("src/webql/assembler.gleam", 46).
-spec assemble_scheduler(webql@assembler@scheduler:scheduler(EBF)) -> {ok,
        webql@assembler@plan:plan(EBF)} |
    {error, webql@assembler@diagnostic:diagnostic()}.
assemble_scheduler(Scheduler) ->
    case webql@assembler@scheduler:schedule(Scheduler) of
        {ok, Result} ->
            {ok, Result};

        {error, Error} ->
            {error,
                {diagnostic, {scheduler_diagnostic, erlang:element(2, Error)}}}
    end.

-file("src/webql/assembler.gleam", 33).
-spec assemble_linker(webql@assembler@linker:linker(), webql@schema:schema(EBA)) -> {ok,
        webql@assembler@linker@program:program(EBA)} |
    {error, webql@assembler@diagnostic:diagnostic()}.
assemble_linker(Linker, Schema) ->
    case webql@assembler@linker:link(Linker, Schema) of
        {ok, Plan} ->
            {ok, Plan};

        {error, Error} ->
            {error, {diagnostic, {linker_diagnostic, erlang:element(2, Error)}}}
    end.

-file("src/webql/assembler.gleam", 20).
?DOC(" Runs an executable plan.\n").
-spec assemble(assembler(EAV), webql@graph:graph()) -> {ok,
        webql@assembler@plan:plan(EAV)} |
    {error, webql@assembler@diagnostic:diagnostic()}.
assemble(Assembler, Graph) ->
    Linker = webql@assembler@linker:new(Graph),
    gleam@result:'try'(
        assemble_linker(Linker, erlang:element(2, Assembler)),
        fun(Plan) ->
            Scheduler = webql@assembler@scheduler:new(Plan),
            assemble_scheduler(Scheduler)
        end
    ).
