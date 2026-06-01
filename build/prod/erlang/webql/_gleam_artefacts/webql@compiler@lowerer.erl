-module(webql@compiler@lowerer).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/lowerer.gleam").
-export([new/1, lower/1]).
-export_type([lowerer/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque lowerer() :: {lowerer, webql@compiler@resolver@hir:document()}.

-file("src/webql/compiler/lowerer.gleam", 10).
?DOC(" Creates a new lowerer instance from a resolver document.\n").
-spec new(webql@compiler@resolver@hir:document()) -> lowerer().
new(Document) ->
    {lowerer, Document}.

-file("src/webql/compiler/lowerer.gleam", 15).
?DOC(" Lowers a resolver document into compiler IR.\n").
-spec lower(lowerer()) -> webql@graph:graph().
lower(Lowerer) ->
    webql@compiler@lowerer@lower_document:lower(erlang:element(2, Lowerer)).
