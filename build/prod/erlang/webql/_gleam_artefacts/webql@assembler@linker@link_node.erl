-module(webql@assembler@linker@link_node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/linker/link_node.gleam").
-export([link/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/assembler/linker/link_node.gleam", 19).
-spec link_resolver(binary(), webql@schema:schema(DMA)) -> {ok,
        webql@schema:resolver(DMA)} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link_resolver(Node, Schema) ->
    {schema, Operations, _} = Schema,
    case gleam_stdlib:map_get(Operations, Node) of
        {ok, {operation, _, Resolver, _}} ->
            {ok, Resolver};

        {error, _} ->
            {error, {diagnostic, {unknown_operation, Node}}}
    end.

-file("src/webql/assembler/linker/link_node.gleam", 8).
?DOC(" Links an external node into a scheduler resolver.\n").
-spec link(binary(), binary(), webql@schema:schema(DLV)) -> {ok,
        {binary(), webql@assembler@linker@program:node_(DLV)}} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link(Name, Node, Schema) ->
    gleam@result:'try'(
        link_resolver(Node, Schema),
        fun(Function) -> {ok, {Name, {node, Function}}} end
    ).
