-module(webql).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql.gleam").
-export([new/2, run/4, introspect/1]).
-export_type([webql/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type webql(GZG, GZH) :: {webql,
        webql@memory:memory(GZG),
        webql@engine:engine(GZH, webql@memory:memory(GZG), webql@diagnostic:diagnostic())}.

-file("src/webql.gleam", 21).
?DOC(" Creates a new WebQL instance.\n").
-spec new(
    webql@memory:memory(GZI),
    webql@engine:engine(GZK, webql@memory:memory(GZI), webql@diagnostic:diagnostic())
) -> webql(GZI, GZK).
new(Memory, Engine) ->
    {webql, Memory, Engine}.

-file("src/webql.gleam", 73).
-spec run_assembler(webql@assembler:assembler(HAC), webql@graph:graph()) -> {ok,
        webql@assembler@plan:plan(HAC)} |
    {error, webql@diagnostic:diagnostic()}.
run_assembler(Assembler, Graph) ->
    case webql@assembler:assemble(Assembler, Graph) of
        {ok, Plan} ->
            {ok, Plan};

        {error, Diagnostic} ->
            {error,
                {diagnostic,
                    {assembler_diagnostic, erlang:element(2, Diagnostic)}}}
    end.

-file("src/webql.gleam", 55).
-spec run_compiler(binary(), webql@schema:schema(any())) -> {ok,
        webql@graph:graph()} |
    {error, webql@diagnostic:diagnostic()}.
run_compiler(Source, Schema) ->
    Introspection_schema = webql@introspection:introspect(Schema),
    Compiler = webql@compiler:new(Introspection_schema),
    case webql@compiler:compile(Compiler, Source) of
        {ok, Output} ->
            {ok, Output};

        {error, Diagnostic} ->
            {error,
                {diagnostic,
                    {compiler_diagnostic, erlang:element(2, Diagnostic)}}}
    end.

-file("src/webql.gleam", 29).
?DOC(" Runs a WebQL source against a schema.\n").
-spec run(
    webql(any(), GZS),
    binary(),
    webql@schema:schema(GZS),
    gleam@dynamic:dynamic_()
) -> GZS.
run(Webql, Source, Schema, Params) ->
    {webql, Memory, Engine} = Webql,
    (erlang:element(2, Engine))(
        fun() ->
            gleam@result:'try'(
                run_compiler(Source, Schema),
                fun(Graph) ->
                    Assembler = webql@assembler:new(Schema),
                    gleam@result:'try'(
                        run_assembler(Assembler, Graph),
                        fun(Plan) ->
                            Runner = webql@runner:new(Plan),
                            {ok,
                                webql@runner:run(Runner, Memory, Engine, Params)}
                        end
                    )
                end
            )
        end
    ).

-file("src/webql.gleam", 49).
?DOC(" Returns introspection results for a WebQL schema.\n").
-spec introspect(webql@schema:schema(any())) -> webql@introspection:schema().
introspect(Schema) ->
    webql@introspection:introspect(Schema).
