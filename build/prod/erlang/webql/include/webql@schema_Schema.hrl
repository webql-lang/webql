-record(schema, {
    operations :: gleam@dict:dict(binary(), webql@schema:operation(any())),
    ports :: list(webql@schema:port_())
}).
