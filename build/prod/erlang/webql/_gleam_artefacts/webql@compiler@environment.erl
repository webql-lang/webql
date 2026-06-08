-module(webql@compiler@environment).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/environment.gleam").
-export([new/0, next_operation/1, add_operation/2, add_operations/2, next_port/1, add_port/2, add_ports/2, add_input/3, add_inputs/3, add_output/3, add_outputs/3, get_inputs/2, get_operation/2, get_outputs/2, get_port/2]).
-export_type([environment/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type environment() :: {environment,
        gleam@dict:dict(webql@compiler@reference:operation(), list({binary(),
            webql@compiler@reference:port_()})),
        gleam@dict:dict(binary(), webql@compiler@reference:operation()),
        gleam@dict:dict(webql@compiler@reference:operation(), list({binary(),
            webql@compiler@reference:port_()})),
        gleam@dict:dict(binary(), webql@compiler@reference:port_())}.

-file("src/webql/compiler/environment.gleam", 16).
?DOC(" Creates a new compiler environment.\n").
-spec new() -> environment().
new() ->
    {environment, maps:new(), maps:new(), maps:new(), maps:new()}.

-file("src/webql/compiler/environment.gleam", 132).
?DOC(" Gets the next stable schema operation reference.\n").
-spec next_operation(environment()) -> webql@compiler@reference:operation().
next_operation(Environment) ->
    {operation, maps:size(erlang:element(3, Environment))}.

-file("src/webql/compiler/environment.gleam", 26).
?DOC(" Adds a schema operation to the current environment instance.\n").
-spec add_operation(environment(), binary()) -> environment().
add_operation(Environment, Operation) ->
    {environment, _, Operations, _, _} = Environment,
    {environment,
        erlang:element(2, Environment),
        gleam@dict:upsert(
            Operations,
            Operation,
            fun(Operation@1) -> case Operation@1 of
                    {some, Operation@2} ->
                        Operation@2;

                    none ->
                        next_operation(Environment)
                end end
        ),
        erlang:element(4, Environment),
        erlang:element(5, Environment)}.

-file("src/webql/compiler/environment.gleam", 44).
?DOC(" Adds schema operations to the current environment instance.\n").
-spec add_operations(environment(), list(binary())) -> environment().
add_operations(Environment, Operations) ->
    gleam@list:fold(Operations, Environment, fun add_operation/2).

-file("src/webql/compiler/environment.gleam", 137).
?DOC(" Gets the next stable port reference.\n").
-spec next_port(environment()) -> webql@compiler@reference:port_().
next_port(Environment) ->
    {port, maps:size(erlang:element(5, Environment))}.

-file("src/webql/compiler/environment.gleam", 52).
?DOC(" Adds a port to the current environment instance.\n").
-spec add_port(environment(), binary()) -> environment().
add_port(Environment, Port) ->
    {environment, _, _, _, Ports} = Environment,
    {environment,
        erlang:element(2, Environment),
        erlang:element(3, Environment),
        erlang:element(4, Environment),
        gleam@dict:upsert(Ports, Port, fun(Port@1) -> case Port@1 of
                    {some, Port@2} ->
                        Port@2;

                    none ->
                        next_port(Environment)
                end end)}.

-file("src/webql/compiler/environment.gleam", 67).
?DOC(" Adds ports to the current environment instance.\n").
-spec add_ports(environment(), list(binary())) -> environment().
add_ports(Environment, Ports) ->
    gleam@list:fold(Ports, Environment, fun add_port/2).

-file("src/webql/compiler/environment.gleam", 72).
?DOC(" Adds a typed input port to the current environment instance.\n").
-spec add_input(
    environment(),
    webql@compiler@reference:operation(),
    {binary(), webql@compiler@reference:port_()}
) -> environment().
add_input(Environment, Operation, Input) ->
    {environment, Inputs, _, _, _} = Environment,
    {environment,
        gleam@dict:upsert(Inputs, Operation, fun(Existing) -> case Existing of
                    {some, Existing@1} ->
                        lists:append(Existing@1, [Input]);

                    none ->
                        [Input]
                end end),
        erlang:element(3, Environment),
        erlang:element(4, Environment),
        erlang:element(5, Environment)}.

-file("src/webql/compiler/environment.gleam", 91).
?DOC(" Adds typed input ports to the current environment instance.\n").
-spec add_inputs(
    environment(),
    webql@compiler@reference:operation(),
    list({binary(), webql@compiler@reference:port_()})
) -> environment().
add_inputs(Environment, Operation, Inputs) ->
    gleam@list:fold(
        Inputs,
        Environment,
        fun(Environment@1, Input) ->
            add_input(Environment@1, Operation, Input)
        end
    ).

-file("src/webql/compiler/environment.gleam", 102).
?DOC(" Adds a typed output port to the current environment instance.\n").
-spec add_output(
    environment(),
    webql@compiler@reference:operation(),
    {binary(), webql@compiler@reference:port_()}
) -> environment().
add_output(Environment, Operation, Output) ->
    {environment, _, _, Outputs, _} = Environment,
    {environment,
        erlang:element(2, Environment),
        erlang:element(3, Environment),
        gleam@dict:upsert(Outputs, Operation, fun(Existing) -> case Existing of
                    {some, Existing@1} ->
                        lists:append(Existing@1, [Output]);

                    none ->
                        [Output]
                end end),
        erlang:element(5, Environment)}.

-file("src/webql/compiler/environment.gleam", 121).
?DOC(" Adds typed output ports to the current environment instance.\n").
-spec add_outputs(
    environment(),
    webql@compiler@reference:operation(),
    list({binary(), webql@compiler@reference:port_()})
) -> environment().
add_outputs(Environment, Operation, Outputs) ->
    gleam@list:fold(
        Outputs,
        Environment,
        fun(Environment@1, Output) ->
            add_output(Environment@1, Operation, Output)
        end
    ).

-file("src/webql/compiler/environment.gleam", 142).
?DOC(" Looks up typed input ports for an operation.\n").
-spec get_inputs(environment(), webql@compiler@reference:operation()) -> {ok,
        list({binary(), webql@compiler@reference:port_()})} |
    {error, nil}.
get_inputs(Environment, Operation) ->
    gleam_stdlib:map_get(erlang:element(2, Environment), Operation).

-file("src/webql/compiler/environment.gleam", 150).
?DOC(" Looks up a schema operation reference by name.\n").
-spec get_operation(environment(), binary()) -> {ok,
        webql@compiler@reference:operation()} |
    {error, nil}.
get_operation(Environment, Operation) ->
    gleam_stdlib:map_get(erlang:element(3, Environment), Operation).

-file("src/webql/compiler/environment.gleam", 158).
?DOC(" Looks up typed output ports for an operation.\n").
-spec get_outputs(environment(), webql@compiler@reference:operation()) -> {ok,
        list({binary(), webql@compiler@reference:port_()})} |
    {error, nil}.
get_outputs(Environment, Operation) ->
    gleam_stdlib:map_get(erlang:element(4, Environment), Operation).

-file("src/webql/compiler/environment.gleam", 166).
?DOC(" Looks up a port reference by name.\n").
-spec get_port(environment(), binary()) -> {ok,
        webql@compiler@reference:port_()} |
    {error, nil}.
get_port(Environment, Port) ->
    gleam_stdlib:map_get(erlang:element(5, Environment), Port).
