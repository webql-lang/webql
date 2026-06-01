-module(webql@assembler@plan).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/assembler/plan.gleam").
-export_type([plan/1, batch/1, step/1, node_/1, edge/0, source/0, target/0]).

-type plan(DQD) :: {plan, list(edge()), list(batch(DQD))}.

-type batch(DQE) :: {batch, list(step(DQE))}.

-type step(DQF) :: {step, binary(), node_(DQF)}.

-type node_(DQG) :: {node, webql@schema:resolver(DQG)} | {supernode, plan(DQG)}.

-type edge() :: {edge, source(), target()}.

-type source() :: {output, list(binary())} | {literal, gleam@dynamic:dynamic_()}.

-type target() :: {input, list(binary())}.


