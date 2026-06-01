-module(webql@memory@kv).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/memory/kv.gleam").
-export([merge/2, set/3, get/2, new/0, encode/1, decode/2]).
-export_type([kv/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type kv() :: {kv, gleam@dict:dict(list(binary()), gleam@dynamic:dynamic_())}.

-file("src/webql/memory/kv.gleam", 43).
?DOC(" Merges two KV stores, using right-hand values when paths conflict.\n").
-spec merge(webql@memory:memory(kv()), webql@memory:memory(kv())) -> webql@memory:memory(kv()).
merge(Left, Right) ->
    {memory, _, Left_kv, _, _, _} = Left,
    {memory, _, Right_kv, _, _, _} = Right,
    Values@1 = gleam@dict:fold(
        erlang:element(2, Right_kv),
        erlang:element(2, Left_kv),
        fun(Values, Path, Value) -> gleam@dict:insert(Values, Path, Value) end
    ),
    {memory,
        erlang:element(2, Left),
        {kv, Values@1},
        erlang:element(4, Left),
        erlang:element(5, Left),
        erlang:element(6, Left)}.

-file("src/webql/memory/kv.gleam", 30).
?DOC(" Inserts a value via a path into KV.\n").
-spec set(webql@memory:memory(kv()), list(binary()), gleam@dynamic:dynamic_()) -> webql@memory:memory(kv()).
set(Memory, Path, Value) ->
    {memory, _, Kv, _, _, _} = Memory,
    {memory,
        erlang:element(2, Memory),
        {kv, gleam@dict:insert(erlang:element(2, Kv), Path, Value)},
        erlang:element(4, Memory),
        erlang:element(5, Memory),
        erlang:element(6, Memory)}.

-file("src/webql/memory/kv.gleam", 18).
?DOC(" Gets a path from KV.\n").
-spec get(webql@memory:memory(kv()), list(binary())) -> {ok,
        gleam@dynamic:dynamic_()} |
    {error, gleam@dynamic:dynamic_()}.
get(Memory, Path) ->
    {memory, _, Kv, _, _, _} = Memory,
    case gleam_stdlib:map_get(erlang:element(2, Kv), Path) of
        {ok, Value} ->
            {ok, Value};

        {error, _} ->
            {error, gleam@dynamic:nil()}
    end.

-file("src/webql/memory/kv.gleam", 12).
?DOC(" Creates a new memory instance constaining KV.\n").
-spec new() -> webql@memory:memory(kv()).
new() ->
    Storage = {kv, maps:new()},
    {memory, fun new/0, Storage, fun get/2, fun set/3, fun merge/2}.

-file("src/webql/memory/kv.gleam", 59).
?DOC(" Encodes a KV store into a dynamic to be used by an external runtime.\n").
-spec encode(webql@memory:memory(kv())) -> gleam@dynamic:dynamic_().
encode(Memory) ->
    {memory, _, Kv, _, _, _} = Memory,
    _pipe = erlang:element(2, Kv),
    _pipe@1 = maps:to_list(_pipe),
    _pipe@4 = gleam@list:map(
        _pipe@1,
        fun(Input) ->
            {Path, Value} = Input,
            Key = begin
                _pipe@2 = Path,
                _pipe@3 = gleam@list:map(_pipe@2, fun gleam_stdlib:identity/1),
                erlang:list_to_tuple(_pipe@3)
            end,
            {Key, Value}
        end
    ),
    gleam@dynamic:properties(_pipe@4).

-file("src/webql/memory/kv.gleam", 77).
?DOC(" Decodes a dynamic (ie. a Erlang map or JS object) by coverting it into a KV value.\n").
-spec decode(webql@memory:memory(kv()), gleam@dynamic:dynamic_()) -> {ok,
        webql@memory:memory(kv())} |
    {error, list(gleam@dynamic@decode:decode_error())}.
decode(Memory, Unknown) ->
    Schema = gleam@dynamic@decode:dict(
        gleam@dynamic@decode:list(
            {decoder, fun gleam@dynamic@decode:decode_string/1}
        ),
        {decoder, fun gleam@dynamic@decode:decode_dynamic/1}
    ),
    Values = gleam@dynamic@decode:run(Unknown, Schema),
    case Values of
        {ok, Values@1} ->
            {ok,
                {memory,
                    erlang:element(2, Memory),
                    {kv, Values@1},
                    erlang:element(4, Memory),
                    erlang:element(5, Memory),
                    erlang:element(6, Memory)}};

        {error, Error} ->
            {error, Error}
    end.
