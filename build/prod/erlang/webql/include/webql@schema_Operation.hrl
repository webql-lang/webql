-record(operation, {
    inputs :: gleam@dict:dict(binary(), webql@schema:input()),
    resolver :: webql@schema:resolver(any()),
    outputs :: gleam@dict:dict(binary(), webql@schema:output())
}).
