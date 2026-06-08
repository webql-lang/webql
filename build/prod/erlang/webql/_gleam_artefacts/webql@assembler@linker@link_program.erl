-module(webql@assembler@linker@link_program).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/linker/link_program.gleam").
-export([link/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/assembler/linker/link_program.gleam", 47).
-spec link_node(webql@graph:node_(), webql@schema:schema(DOL)) -> {ok,
        {binary(), webql@assembler@linker@program:node_(DOL)}} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link_node(Node, Schema) ->
    case Node of
        {node, Name, Node@1} ->
            webql@assembler@linker@link_node:link(Name, Node@1, Schema);

        {supernode, Name@1, Graph} ->
            gleam@result:'try'(
                link_program(Graph, Schema),
                fun(Program) -> {ok, {Name@1, {supernode, Program}}} end
            )
    end.

-file("src/webql/assembler/linker/link_program.gleam", 32).
-spec link_nodes(
    list(webql@graph:node_()),
    webql@schema:schema(DOB),
    gleam@dict:dict(binary(), webql@assembler@linker@program:node_(DOB))
) -> {ok, gleam@dict:dict(binary(), webql@assembler@linker@program:node_(DOB))} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link_nodes(Nodes, Schema, Linked) ->
    case Nodes of
        [Node | Nodes@1] ->
            gleam@result:'try'(
                link_node(Node, Schema),
                fun(_use0) ->
                    {Name, Resolver} = _use0,
                    link_nodes(
                        Nodes@1,
                        Schema,
                        gleam@dict:insert(Linked, Name, Resolver)
                    )
                end
            );

        [] ->
            {ok, Linked}
    end.

-file("src/webql/assembler/linker/link_program.gleam", 20).
-spec link_program(webql@graph:graph(), webql@schema:schema(DNV)) -> {ok,
        webql@assembler@linker@program:program(DNV)} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link_program(Graph, Schema) ->
    {graph, _, _, Nodes, Edges} = Graph,
    gleam@result:'try'(
        link_nodes(Nodes, Schema, maps:new()),
        fun(Nodes@1) ->
            Edges@1 = webql@assembler@linker@link_route:link(Edges),
            {ok, {program, Nodes@1, Edges@1}}
        end
    ).

-file("src/webql/assembler/linker/link_program.gleam", 11).
?DOC(" Links a graph into a scheduler program.\n").
-spec link(webql@graph:graph(), webql@schema:schema(DNQ)) -> {ok,
        webql@assembler@linker@program:program(DNQ)} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link(Graph, Schema) ->
    link_program(Graph, Schema).
