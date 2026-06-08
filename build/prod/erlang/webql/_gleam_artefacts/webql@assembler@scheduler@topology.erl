-module(webql@assembler@scheduler@topology).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/scheduler/topology.gleam").
-export([topology/1]).
-export_type([graph/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type graph() :: {graph, gleam@dict:dict(binary(), gleam@set:set(binary()))}.

-file("src/webql/assembler/scheduler/topology.gleam", 56).
-spec drop_dependencies(
    gleam@dict:dict(binary(), gleam@set:set(binary())),
    list(binary())
) -> gleam@dict:dict(binary(), gleam@set:set(binary())).
drop_dependencies(Dependencies, Batch) ->
    Dependencies@2 = gleam@list:fold(
        Batch,
        Dependencies,
        fun(Dependencies@1, Node) -> gleam@dict:delete(Dependencies@1, Node) end
    ),
    _pipe = Dependencies@2,
    _pipe@1 = maps:to_list(_pipe),
    gleam@list:fold(
        _pipe@1,
        maps:new(),
        fun(Dependencies@3, Pair) ->
            {Node@1, Upstream} = Pair,
            Upstream@2 = gleam@list:fold(
                Batch,
                Upstream,
                fun(Upstream@1, Node@2) ->
                    gleam@set:delete(Upstream@1, Node@2)
                end
            ),
            gleam@dict:insert(Dependencies@3, Node@1, Upstream@2)
        end
    ).

-file("src/webql/assembler/scheduler/topology.gleam", 45).
-spec toposort_batch(gleam@dict:dict(binary(), gleam@set:set(binary()))) -> list(binary()).
toposort_batch(Dependencies) ->
    _pipe = Dependencies,
    _pipe@1 = maps:to_list(_pipe),
    gleam@list:filter_map(
        _pipe@1,
        fun(Pair) ->
            {Node, Upstream} = Pair,
            gleam@bool:guard(
                not gleam@set:is_empty(Upstream),
                {error, nil},
                fun() -> {ok, Node} end
            )
        end
    ).

-file("src/webql/assembler/scheduler/topology.gleam", 21).
-spec toposort(
    gleam@dict:dict(binary(), gleam@set:set(binary())),
    list(list(binary()))
) -> {ok, list(list(binary()))} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
toposort(Dependencies, Batches) ->
    gleam@bool:guard(
        gleam@dict:is_empty(Dependencies),
        {ok, lists:reverse(Batches)},
        fun() -> case toposort_batch(Dependencies) of
                [_ | _] = Batch ->
                    _pipe = Dependencies,
                    _pipe@1 = drop_dependencies(_pipe, Batch),
                    toposort(_pipe@1, [Batch | Batches]);

                [] ->
                    {error,
                        {diagnostic, {cycle_detected, maps:keys(Dependencies)}}}
            end end
    ).

-file("src/webql/assembler/scheduler/topology.gleam", 12).
?DOC(" Topologically sorts a graph into batches of node names.\n").
-spec topology(graph()) -> {ok, list(list(binary()))} |
    {error, webql@assembler@scheduler@diagnostic:diagnostic()}.
topology(Graph) ->
    {graph, Dependencies} = Graph,
    toposort(Dependencies, []).
