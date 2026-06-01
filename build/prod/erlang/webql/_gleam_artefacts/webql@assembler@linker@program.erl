-module(webql@assembler@linker@program).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/linker/program.gleam").
-export_type([program/1, node_/1, edge/0, source/0, target/0]).

-type program(DLK) :: {program,
        gleam@dict:dict(binary(), node_(DLK)),
        list(edge())}.

-type node_(DLL) :: {node, webql@schema:resolver(DLL)} |
    {supernode, program(DLL)}.

-type edge() :: {edge, source(), target()}.

-type source() :: {output, list(binary())} | {literal, gleam@dynamic:dynamic_()}.

-type target() :: {input, list(binary())}.


