-module(webql@engine).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/engine.gleam").
-export_type([engine/3]).

-type engine(GGE, GGF, GGG) :: {engine,
        fun((fun(() -> {ok, GGE} | {error, GGG})) -> GGE),
        fun((fun(() -> {ok, {GGF, list(fun((GGF) -> GGE))}} |
            {error, webql@interpreter@diagnostic:diagnostic()})) -> GGE),
        fun((GGE, fun((GGF) -> {ok, gleam@dynamic:dynamic_()} |
            {error, webql@interpreter@diagnostic:diagnostic()})) -> GGE),
        fun((fun(() -> {ok, list(GGE)} |
            {error, webql@interpreter@diagnostic:diagnostic()})) -> GGE),
        fun((GGF, GGE, fun((GGF, GGF) -> GGF)) -> GGE),
        fun((fun(() -> {ok, GGE} |
            {error, webql@interpreter@diagnostic:diagnostic()})) -> GGE),
        fun((GGE, fun(({ok, gleam@dynamic:dynamic_()} |
            {error, gleam@dynamic:dynamic_()}) -> {ok, GGF} |
            {error, webql@interpreter@diagnostic:diagnostic()})) -> GGE)}.


