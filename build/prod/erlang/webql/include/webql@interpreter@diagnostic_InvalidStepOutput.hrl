-record(invalid_step_output, {
    step :: binary(),
    errors :: list(gleam@dynamic@decode:decode_error())
}).
