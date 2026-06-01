-module(webql@compiler@typechecker).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/typechecker.gleam").
-export([new/1, resolve/2]).
-export_type([typechecker/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-opaque typechecker() :: {typechecker, webql@compiler@resolver@hir:document()}.

-file("src/webql/compiler/typechecker.gleam", 11).
?DOC(" Creates a new typechecker instance from a resolver document.\n").
-spec new(webql@compiler@resolver@hir:document()) -> typechecker().
new(Document) ->
    {typechecker, Document}.

-file("src/webql/compiler/typechecker.gleam", 16).
?DOC(" Typechecks a resolver document.\n").
-spec resolve(typechecker(), webql@compiler@context:context()) -> {ok,
        webql@compiler@resolver@hir:document()} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
resolve(Typechecker, Context) ->
    webql@compiler@typechecker@typecheck_document:typecheck(
        erlang:element(2, Typechecker),
        Context
    ).
