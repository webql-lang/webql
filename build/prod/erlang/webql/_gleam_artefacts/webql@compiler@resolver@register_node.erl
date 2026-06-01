-module(webql@compiler@resolver@register_node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/resolver/register_node.gleam").
-export([register/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/resolver/register_node.gleam", 53).
-spec register_outputs(
    webql@compiler@context:context(),
    binary(),
    list({binary(), webql@compiler@reference:port_()})
) -> webql@compiler@context:context().
register_outputs(Context, Name, Outputs) ->
    gleam@list:fold(
        Outputs,
        Context,
        fun(Context@1, Output) ->
            {Port, Reference} = Output,
            webql@compiler@context:add_output(
                Context@1,
                [Name, Port],
                Reference
            )
        end
    ).

-file("src/webql/compiler/resolver/register_node.gleam", 42).
-spec register_inputs(
    webql@compiler@context:context(),
    binary(),
    list({binary(), webql@compiler@reference:port_()})
) -> webql@compiler@context:context().
register_inputs(Context, Name, Inputs) ->
    gleam@list:fold(
        Inputs,
        Context,
        fun(Context@1, Input) ->
            {Port, Reference} = Input,
            webql@compiler@context:add_input(Context@1, [Name, Port], Reference)
        end
    ).

-file("src/webql/compiler/resolver/register_node.gleam", 25).
-spec register_operation_ports(
    webql@compiler@context:context(),
    webql@compiler@environment:environment(),
    binary(),
    webql@compiler@reference:operation()
) -> webql@compiler@context:context().
register_operation_ports(Context, Environment, Name, Operation) ->
    Context@1 = case webql@compiler@environment:get_inputs(
        Environment,
        Operation
    ) of
        {ok, Inputs} ->
            register_inputs(Context, Name, Inputs);

        {error, _} ->
            Context
    end,
    case webql@compiler@environment:get_outputs(Environment, Operation) of
        {ok, Outputs} ->
            register_outputs(Context@1, Name, Outputs);

        {error, _} ->
            Context@1
    end.

-file("src/webql/compiler/resolver/register_node.gleam", 8).
?DOC(" Registers a node.\n").
-spec register(
    webql@compiler@environment:environment(),
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:node_()
) -> webql@compiler@context:context().
register(Environment, Context, Node) ->
    Context@1 = webql@compiler@context:add_node(
        Context,
        erlang:element(2, Node)
    ),
    case Node of
        {node, Name, _, Operation, _, _} ->
            register_operation_ports(Context@1, Environment, Name, Operation);

        {supernode, _, _, _, _} ->
            Context@1
    end.
