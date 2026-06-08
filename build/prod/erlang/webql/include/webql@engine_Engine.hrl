-record(engine, {
    handle_run :: fun((fun(() -> {ok, any()} | {error, any()})) -> any()),
    handle_start_plan :: fun((fun(() -> {ok,
            {any(), list(fun((any()) -> any()))}} |
        {error, webql@runner@diagnostic:diagnostic()})) -> any()),
    handle_finish_plan :: fun((any(), fun((any()) -> {ok,
            gleam@dynamic:dynamic_()} |
        {error, webql@runner@diagnostic:diagnostic()})) -> any()),
    handle_start_batch :: fun((fun(() -> {ok, list(any())} |
        {error, webql@runner@diagnostic:diagnostic()})) -> any()),
    handle_finish_batch :: fun((any(), any(), fun((any(), any()) -> any())) -> any()),
    handle_start_step :: fun((fun(() -> {ok, any()} |
        {error, webql@runner@diagnostic:diagnostic()})) -> any()),
    handle_finish_step :: fun((any(), fun(({ok, gleam@dynamic:dynamic_()} |
        {error, gleam@dynamic:dynamic_()}) -> {ok, any()} |
        {error, webql@runner@diagnostic:diagnostic()})) -> any())
}).
