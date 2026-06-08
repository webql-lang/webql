-module(webql@runner@run).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/runner/run.gleam").
-export([add_parameters/2, add_outputs/3, get_inputs/3, get_returns/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/runner/run.gleam", 134).
-spec decode(gleam@dynamic:dynamic_()) -> {ok,
        gleam@dict:dict(binary(), gleam@dynamic:dynamic_())} |
    {error, list(gleam@dynamic@decode:decode_error())}.
decode(Unknown) ->
    Schema = gleam@dynamic@decode:dict(
        {decoder, fun gleam@dynamic@decode:decode_string/1},
        {decoder, fun gleam@dynamic@decode:decode_dynamic/1}
    ),
    gleam@dynamic@decode:run(Unknown, Schema).

-file("src/webql/runner/run.gleam", 11).
?DOC(" Stores initial plan parameters as root-level values.\n").
-spec add_parameters(webql@memory:memory(GMA), gleam@dynamic:dynamic_()) -> {ok,
        webql@memory:memory(GMA)} |
    {error, webql@runner@diagnostic:diagnostic()}.
add_parameters(Memory, Parameters) ->
    case decode(Parameters) of
        {ok, Parameters@1} ->
            Memory@2 = gleam@dict:fold(
                Parameters@1,
                Memory,
                fun(Memory@1, Name, Value) ->
                    (erlang:element(5, Memory@1))(Memory@1, [Name], Value)
                end
            ),
            {ok, Memory@2};

        {error, Errors} ->
            {error, {diagnostic, {invalid_parameters, Errors}}}
    end.

-file("src/webql/runner/run.gleam", 31).
?DOC(" Stores outputs produced by a completed step.\n").
-spec add_outputs(webql@memory:memory(GMF), binary(), gleam@dynamic:dynamic_()) -> {ok,
        webql@memory:memory(GMF)} |
    {error, webql@runner@diagnostic:diagnostic()}.
add_outputs(Memory, Step, Outputs) ->
    case decode(Outputs) of
        {ok, Outputs@1} ->
            Memory@2 = gleam@dict:fold(
                Outputs@1,
                Memory,
                fun(Memory@1, Name, Value) ->
                    (erlang:element(5, Memory@1))(Memory@1, [Step, Name], Value)
                end
            ),
            {ok, Memory@2};

        {error, Errors} ->
            {error, {diagnostic, {invalid_step_output, Step, Errors}}}
    end.

-file("src/webql/runner/run.gleam", 124).
-spec encode(gleam@dict:dict(binary(), gleam@dynamic:dynamic_())) -> gleam@dynamic:dynamic_().
encode(Values) ->
    _pipe = Values,
    _pipe@1 = maps:to_list(_pipe),
    _pipe@2 = gleam@list:map(
        _pipe@1,
        fun(Input) ->
            {Key, Value} = Input,
            {gleam_stdlib:identity(Key), Value}
        end
    ),
    gleam@dynamic:properties(_pipe@2).

-file("src/webql/runner/run.gleam", 54).
?DOC(" Resolves all input values for a step by following edges that target it.\n").
-spec get_inputs(
    webql@memory:memory(any()),
    binary(),
    list(webql@assembler@plan:edge())
) -> {ok, gleam@dynamic:dynamic_()} |
    {error, webql@runner@diagnostic:diagnostic()}.
get_inputs(Memory, Step, Edges) ->
    Inputs = maps:new(),
    Results = gleam@list:try_fold(
        Edges,
        Inputs,
        fun(Inputs@1, Edge) -> case Edge of
                {edge, {output, Source}, {input, [Target, Input]}} when Target =:= Step ->
                    gleam@result:'try'(
                        (erlang:element(4, Memory))(Memory, Source),
                        fun(Value) ->
                            {ok, gleam@dict:insert(Inputs@1, Input, Value)}
                        end
                    );

                {edge, {literal, Value@1}, {input, [Target@1, Input@1]}} when Target@1 =:= Step ->
                    {ok, gleam@dict:insert(Inputs@1, Input@1, Value@1)};

                _ ->
                    {ok, Inputs@1}
            end end
    ),
    case Results of
        {ok, Results@1} ->
            {ok, encode(Results@1)};

        {error, Message} ->
            {error, {diagnostic, {missing_step_input, Step, Message}}}
    end.

-file("src/webql/runner/run.gleam", 94).
?DOC(" Resolves final return values from root-level values.\n").
-spec get_returns(webql@memory:memory(any()), list(webql@assembler@plan:edge())) -> {ok,
        gleam@dynamic:dynamic_()} |
    {error, gleam@dynamic:dynamic_()}.
get_returns(Memory, Edges) ->
    gleam@result:'try'(
        gleam@list:try_fold(
            Edges,
            maps:new(),
            fun(Returns, Edge) -> case Edge of
                    {edge, {output, Source}, {input, [Output]}} ->
                        gleam@result:'try'(
                            (erlang:element(4, Memory))(Memory, Source),
                            fun(Value) ->
                                {ok, gleam@dict:insert(Returns, Output, Value)}
                            end
                        );

                    {edge, {literal, Value@1}, {input, [Output@1]}} ->
                        {ok, gleam@dict:insert(Returns, Output@1, Value@1)};

                    _ ->
                        {ok, Returns}
                end end
        ),
        fun(Returns@1) -> {ok, encode(Returns@1)} end
    ).
