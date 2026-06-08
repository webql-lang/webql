-record(operation, {
    name :: binary(),
    inputs :: list(webql@introspection:input()),
    outputs :: list(webql@introspection:output())
}).
