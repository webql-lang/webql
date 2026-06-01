-module(webql@assembler@scheduler@schedule_plan).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/scheduler/schedule_plan.gleam").
-export([schedule/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 38).
-spec schedule_edges(list(webql@assembler@linker@program:edge())) -> list(webql@assembler@plan:edge()).
schedule_edges(Edges) ->
    gleam@list:map(Edges, fun(Edge) -> case Edge of
                {edge, {output, Source}, {input, Target}} ->
                    {edge, {output, Source}, {input, Target}};

                {edge, {literal, Value}, {input, Target@1}} ->
                    {edge, {literal, Value}, {input, Target@1}}
            end end).

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 103).
-spec schedule_node(webql@assembler@linker@program:node_(DWQ)) -> {ok,
        webql@assembler@plan:node_(DWQ)} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule_node(Node) ->
    case Node of
        {node, Resolver} ->
            {ok, {node, Resolver}};

        {supernode, Program} ->
            gleam@result:'try'(
                schedule(Program),
                fun(Plan) -> {ok, {supernode, Plan}} end
            )
    end.

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 93).
-spec schedule_step(
    gleam@dict:dict(binary(), webql@assembler@linker@program:node_(DWJ)),
    binary()
) -> {ok, webql@assembler@plan:node_(DWJ)} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule_step(Nodes, Node) ->
    case gleam_stdlib:map_get(Nodes, Node) of
        {ok, Node@1} ->
            schedule_node(Node@1);

        {error, _} ->
            {error, {diagnostic, invalid_plan}}
    end.

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 78).
-spec schedule_batch(
    list(binary()),
    gleam@dict:dict(binary(), webql@assembler@linker@program:node_(DVZ)),
    list(webql@assembler@plan:step(DVZ))
) -> {ok, list(webql@assembler@plan:step(DVZ))} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule_batch(Batch, Nodes, Steps) ->
    case Batch of
        [Name | Batch@1] ->
            gleam@result:'try'(
                schedule_step(Nodes, Name),
                fun(Node) ->
                    schedule_batch(Batch@1, Nodes, [{step, Name, Node} | Steps])
                end
            );

        [] ->
            {ok, lists:reverse(Steps)}
    end.

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 62).
-spec schedule_batches(
    list(list(binary())),
    gleam@dict:dict(binary(), webql@assembler@linker@program:node_(DVQ))
) -> {ok, list(webql@assembler@plan:batch(DVQ))} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule_batches(Batches, Nodes) ->
    case Batches of
        [Batch | Batches@1] ->
            gleam@result:'try'(
                schedule_batch(Batch, Nodes, []),
                fun(Steps) ->
                    gleam@result:'try'(
                        schedule_batches(Batches@1, Nodes),
                        fun(Batches@2) -> {ok, [{batch, Steps} | Batches@2]} end
                    )
                end
            );

        [] ->
            {ok, []}
    end.

-file("src/webql/assembler/scheduler/schedule_plan.gleam", 12).
?DOC(" Builds an executable plan from a linker program.\n").
-spec schedule(webql@assembler@linker@program:program(DVH)) -> {ok,
        webql@assembler@plan:plan(DVH)} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
schedule(Program) ->
    {program, Nodes, Edges} = Program,
    Dependencies@1 = begin
        _pipe = Nodes,
        _pipe@1 = maps:keys(_pipe),
        gleam@list:fold(
            _pipe@1,
            maps:new(),
            fun(Dependencies, Node) ->
                gleam@dict:insert(Dependencies, Node, gleam@set:new())
            end
        )
    end,
    Dependencies@3 = gleam@list:fold(
        Edges,
        Dependencies@1,
        fun(Dependencies@2, Edge) ->
            webql@assembler@scheduler@schedule_route:schedule(
                Dependencies@2,
                Edge
            )
        end
    ),
    gleam@result:'try'(
        webql@assembler@scheduler@topology:topology({graph, Dependencies@3}),
        fun(Batches) ->
            gleam@result:'try'(
                schedule_batches(Batches, Nodes),
                fun(Batches@1) ->
                    Edges@1 = schedule_edges(Edges),
                    {ok, {plan, Edges@1, Batches@1}}
                end
            )
        end
    ).
