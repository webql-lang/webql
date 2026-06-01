-module(webql@schema).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/schema.gleam").
-export_type([schema/1, operation/1, port_/0, resolver/1, input/0, output/0]).

-type schema(DKX) :: {schema,
        gleam@dict:dict(binary(), operation(DKX)),
        list(port_())}.

-type operation(DKY) :: {operation,
        gleam@dict:dict(binary(), input()),
        resolver(DKY),
        gleam@dict:dict(binary(), output())}.

-type port_() :: {port, binary()}.

-type resolver(DKZ) :: {resolver, fun((gleam@dynamic:dynamic_()) -> DKZ)}.

-type input() :: {input, binary(), binary()}.

-type output() :: {output, binary(), binary()}.


