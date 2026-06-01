-record(environment, {
    inputs :: gleam@dict:dict(webql@compiler@reference:operation(), list({binary(),
        webql@compiler@reference:port_()})),
    operations :: gleam@dict:dict(binary(), webql@compiler@reference:operation()),
    outputs :: gleam@dict:dict(webql@compiler@reference:operation(), list({binary(),
        webql@compiler@reference:port_()})),
    ports :: gleam@dict:dict(binary(), webql@compiler@reference:port_())
}).
