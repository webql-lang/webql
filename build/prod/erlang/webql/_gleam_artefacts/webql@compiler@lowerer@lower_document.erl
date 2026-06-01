-module(webql@compiler@lowerer@lower_document).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer/lower_document.gleam").
-export([lower/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/lowerer/lower_document.gleam", 6).
?DOC(" Lowers a resolved document into IR.\n").
-spec lower(webql@compiler@resolver@hir:document()) -> webql@graph:graph().
lower(Document) ->
    webql@compiler@lowerer@lower_graph:lower(erlang:element(2, Document)).
