-record(memory, {
    new :: fun(() -> webql@memory:memory(any())),
    store :: any(),
    get :: fun((webql@memory:memory(any()), list(binary())) -> {ok,
            gleam@dynamic:dynamic_()} |
        {error, gleam@dynamic:dynamic_()}),
    set :: fun((webql@memory:memory(any()), list(binary()), gleam@dynamic:dynamic_()) -> webql@memory:memory(any())),
    merge :: fun((webql@memory:memory(any()), webql@memory:memory(any())) -> webql@memory:memory(any()))
}).
