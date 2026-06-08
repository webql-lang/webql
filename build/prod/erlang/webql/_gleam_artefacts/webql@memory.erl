-module(webql@memory).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/webql/memory.gleam").
-export([merge/2, set/3, get/2, new/0, encode/1, decode/2]).
-export_type([memory/1, store/0]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

-type memory(GHW) :: {memory,
        fun(() -> memory(GHW)),
        GHW,
        fun((memory(GHW), list(binary())) -> {ok, gleam@dynamic:dynamic_()} |
            {error, gleam@dynamic:dynamic_()}),
        fun((memory(GHW), list(binary()), gleam@dynamic:dynamic_()) -> memory(GHW)),
        fun((memory(GHW), memory(GHW)) -> memory(GHW))}.

-opaque store() :: {store,
        gleam@dict:dict(list(binary()), gleam@dynamic:dynamic_())}.

-file("src/webql/memory.gleam", 61).
?DOC(" Merges two KV stores, using right-hand values when paths conflict.\n").
-spec merge(memory(store()), memory(store())) -> memory(store()).
merge(Left, Right) ->
    {memory, _, {store, Left_store}, _, _, _} = Left,
    {memory, _, {store, Right_store}, _, _, _} = Right,
    Values@1 = gleam@dict:fold(
        Right_store,
        Left_store,
        fun(Values, Path, Value) -> gleam@dict:insert(Values, Path, Value) end
    ),
    {memory,
        erlang:element(2, Left),
        {store, Values@1},
        erlang:element(4, Left),
        erlang:element(5, Left),
        erlang:element(6, Left)}.

-file("src/webql/memory.gleam", 51).
?DOC(" Inserts a value via a path into KV.\n").
-spec set(memory(store()), list(binary()), gleam@dynamic:dynamic_()) -> memory(store()).
set(Memory, Path, Value) ->
    {memory, _, {store, Store}, _, _, _} = Memory,
    {memory,
        erlang:element(2, Memory),
        {store, gleam@dict:insert(Store, Path, Value)},
        erlang:element(4, Memory),
        erlang:element(5, Memory),
        erlang:element(6, Memory)}.

-file("src/webql/memory.gleam", 39).
?DOC(" Gets a path from KV.\n").
-spec get(memory(store()), list(binary())) -> {ok, gleam@dynamic:dynamic_()} |
    {error, gleam@dynamic:dynamic_()}.
get(Memory, Path) ->
    {memory, _, {store, Store}, _, _, _} = Memory,
    case gleam_stdlib:map_get(Store, Path) of
        {ok, Value} ->
            {ok, Value};

        {error, _} ->
            {error, gleam@dynamic:nil()}
    end.

-file("src/webql/memory.gleam", 33).
?DOC(" Creates a new memory instance constaining KV.\n").
-spec new() -> memory(store()).
new() ->
    Store = {store, maps:new()},
    {memory, fun new/0, Store, fun get/2, fun set/3, fun merge/2}.

-file("src/webql/memory.gleam", 74).
?DOC(" Encodes a KV store into a dynamic to be used by an external runtime.\n").
-spec encode(memory(store())) -> gleam@dynamic:dynamic_().
encode(Memory) ->
    {memory, _, {store, Store}, _, _, _} = Memory,
    _pipe = Store,
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

-file("src/webql/memory.gleam", 92).
?DOC(" Decodes a dynamic (ie. a Erlang map or JS object) by coverting it into a KV value.\n").
-spec decode(memory(store()), gleam@dynamic:dynamic_()) -> {ok, memory(store())} |
    {error, list(gleam@dynamic@decode:decode_error())}.
decode(Memory, Unknown) ->
    Schema = gleam@dynamic@decode:dict(
        gleam@dynamic@decode:list(
            {decoder, fun gleam@dynamic@decode:decode_string/1}
        ),
        {decoder, fun gleam@dynamic@decode:decode_dynamic/1}
    ),
    Store = gleam@dynamic@decode:run(Unknown, Schema),
    case Store of
        {ok, Values} ->
            {ok,
                {memory,
                    erlang:element(2, Memory),
                    {store, Values},
                    erlang:element(4, Memory),
                    erlang:element(5, Memory),
                    erlang:element(6, Memory)}};

        {error, Error} ->
            {error, Error}
    end.
