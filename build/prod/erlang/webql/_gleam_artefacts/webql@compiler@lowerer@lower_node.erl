-module(webql@compiler@lowerer@lower_node).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_node.gleam").
-export([lower/3]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_node.gleam", 4).
?DOC(" Lowers a resolved node reference into an IR node.\n").
-spec lower(binary(), binary(), list({binary(), webql@graph:graph()})) -> webql@graph:node_().
lower(Name, Node, Supernodes) ->
    case Supernodes of
        [{Supernode, Graph} | _] when Supernode =:= Node ->
            {supernode, Name, Graph};

        [_ | Supernodes@1] ->
            lower(Name, Node, Supernodes@1);

        [] ->
            {node, Name, Node}
    end.
