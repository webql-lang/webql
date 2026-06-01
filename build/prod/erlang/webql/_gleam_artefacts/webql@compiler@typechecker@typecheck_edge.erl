-module(webql@compiler@typechecker@typecheck_edge).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/compiler/typechecker/typecheck_edge.gleam").
-export([typecheck/2]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-file("src/webql/compiler/typechecker/typecheck_edge.gleam", 54).
-spec get_output(
    webql@compiler@context:context(),
    list(binary()),
    webql@compiler@source:span()
) -> {ok, {webql@compiler@reference:output(), webql@compiler@reference:port_()}} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
get_output(Context, Path, Span) ->
    case webql@compiler@context:get_output(Context, Path) of
        {ok, Output} ->
            {ok, Output};

        {error, _} ->
            {error, {diagnostic, {unknown_output, Path}, Span}}
    end.

-file("src/webql/compiler/typechecker/typecheck_edge.gleam", 27).
-spec get_port_source(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:source()
) -> {ok, webql@compiler@reference:port_()} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
get_port_source(Context, Source) ->
    case Source of
        {output, Path, _, Span} ->
            gleam@result:'try'(
                get_output(Context, Path, Span),
                fun(_use0) ->
                    {_, Port} = _use0,
                    {ok, Port}
                end
            );

        {literal, _, Port@1, _} ->
            {ok, Port@1}
    end.

-file("src/webql/compiler/typechecker/typecheck_edge.gleam", 46).
-spec get_input(
    webql@compiler@context:context(),
    list(binary()),
    webql@compiler@source:span()
) -> {ok, {webql@compiler@reference:input(), webql@compiler@reference:port_()}} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
get_input(Context, Path, Span) ->
    case webql@compiler@context:get_input(Context, Path) of
        {ok, Input} ->
            {ok, Input};

        {error, _} ->
            {error, {diagnostic, {unknown_input, Path}, Span}}
    end.

-file("src/webql/compiler/typechecker/typecheck_edge.gleam", 39).
-spec get_port_target(
    webql@compiler@context:context(),
    webql@compiler@resolver@hir:target()
) -> {ok, webql@compiler@reference:port_()} |
    {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
get_port_target(Context, Target) ->
    {input, Path, _, Span} = Target,
    gleam@result:'try'(
        get_input(Context, Path, Span),
        fun(_use0) ->
            {_, Port} = _use0,
            {ok, Port}
        end
    ).

-file("src/webql/compiler/typechecker/typecheck_edge.gleam", 7).
?DOC(" Typechecks a resolved edge.\n").
-spec typecheck(
    webql@compiler@resolver@hir:edge(),
    webql@compiler@context:context()
) -> {ok, nil} | {error, webql@compiler@typechecker@diagnostic:diagnostic()}.
typecheck(Edge, Context) ->
    {edge, Source, Target, _, Span} = Edge,
    gleam@result:'try'(
        get_port_target(Context, Target),
        fun(Expected) ->
            gleam@result:'try'(
                get_port_source(Context, Source),
                fun(Found) -> case {Expected, Found} of
                        {Expected@1, Found@1} when Expected@1 =:= Found@1 ->
                            {ok, nil};

                        {_, _} ->
                            {error,
                                {diagnostic,
                                    {type_mismatch, Expected, Found},
                                    Span}}
                    end end
            )
        end
    ).
