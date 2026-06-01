-module(webql@memory).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/memory.gleam").
-export_type([memory/1]).

-type memory(GHW) :: {memory,
        fun(() -> memory(GHW)),
        GHW,
        fun((memory(GHW), list(binary())) -> {ok, gleam@dynamic:dynamic_()} |
            {error, gleam@dynamic:dynamic_()}),
        fun((memory(GHW), list(binary()), gleam@dynamic:dynamic_()) -> memory(GHW)),
        fun((memory(GHW), memory(GHW)) -> memory(GHW))}.


