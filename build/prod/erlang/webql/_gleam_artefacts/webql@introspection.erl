-module(webql@introspection).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/introspection.gleam").
-export([introspect/1]).
-export_type([schema/0, operation/0, input/0, output/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type schema() :: {schema, list(operation()), list(binary())}.

-type operation() :: {operation, binary(), list(input()), list(output())}.

-type input() :: {input, binary(), binary()}.

-type output() :: {output, binary(), binary()}.

-file("src/webql/introspection.gleam", 33).
-spec introspect_ports(list(webql@schema:port_())) -> list(binary()).
introspect_ports(Ports) ->
    gleam@list:map(Ports, fun(Port) -> erlang:element(2, Port) end).

-file("src/webql/introspection.gleam", 67).
-spec introspect_returns(gleam@dict:dict(binary(), webql@schema:output())) -> list(output()).
introspect_returns(Outputs) ->
    _pipe = Outputs,
    _pipe@1 = maps:values(_pipe),
    gleam@list:map(
        _pipe@1,
        fun(Output) ->
            {output, Name, Port} = Output,
            {output, Name, Port}
        end
    ).

-file("src/webql/introspection.gleam", 58).
-spec introspect_parameters(gleam@dict:dict(binary(), webql@schema:input())) -> list(input()).
introspect_parameters(Inputs) ->
    _pipe = Inputs,
    _pipe@1 = maps:values(_pipe),
    gleam@list:map(
        _pipe@1,
        fun(Input) ->
            {input, Name, Port} = Input,
            {input, Name, Port}
        end
    ).

-file("src/webql/introspection.gleam", 48).
-spec introspect_operation(binary(), webql@schema:operation(any())) -> operation().
introspect_operation(Name, Operation) ->
    {operation, Inputs, _, Outputs} = Operation,
    {operation,
        Name,
        introspect_parameters(Inputs),
        introspect_returns(Outputs)}.

-file("src/webql/introspection.gleam", 37).
-spec introspect_operations(
    gleam@dict:dict(binary(), webql@schema:operation(any()))
) -> list(operation()).
introspect_operations(Operations) ->
    _pipe = Operations,
    _pipe@1 = maps:to_list(_pipe),
    gleam@list:map(
        _pipe@1,
        fun(Entry) ->
            {Name, Operation} = Entry,
            introspect_operation(Name, Operation)
        end
    ).

-file("src/webql/introspection.gleam", 22).
?DOC(" Builds the public schema exposed by a runtime schema.\n").
-spec introspect(webql@schema:schema(any())) -> schema().
introspect(Schema) ->
    {schema, Operations, Ports} = Schema,
    Operations@1 = introspect_operations(Operations),
    Ports@1 = introspect_ports(Ports),
    {schema, Operations@1, Ports@1}.
