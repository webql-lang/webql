-module(webql@assembler@linker).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/linker.gleam").
-export([new/1, link/2]).
-export_type([linker/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque linker() :: {linker, webql@graph:graph()}.

-file("src/webql/assembler/linker.gleam", 12).
?DOC(" Creates a new linker instance from a graph.\n").
-spec new(webql@graph:graph()) -> linker().
new(Graph) ->
    {linker, Graph}.

-file("src/webql/assembler/linker.gleam", 17).
?DOC(" Links a graph into a scheduler program.\n").
-spec link(linker(), webql@schema:schema(DPW)) -> {ok,
        webql@assembler@linker@program:program(DPW)} |
    {error, webql@assembler@linker@diagnostic:diagnostic()}.
link(Linker, Schema) ->
    webql@assembler@linker@link_program:link(erlang:element(2, Linker), Schema).
