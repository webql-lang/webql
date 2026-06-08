-record(context, {
    nodes :: gleam@dict:dict(binary(), webql@compiler@reference:node_()),
    supernodes :: gleam@dict:dict(binary(), webql@compiler@reference:supernode()),
    edges :: gleam@dict:dict(webql@compiler@reference:input(), webql@compiler@reference:edge()),
    inputs :: gleam@dict:dict(list(binary()), {webql@compiler@reference:input(),
        webql@compiler@reference:port_()}),
    outputs :: gleam@dict:dict(list(binary()), {webql@compiler@reference:output(),
        webql@compiler@reference:port_()}),
    parameters :: gleam@dict:dict(binary(), webql@compiler@reference:parameter()),
    returns :: gleam@dict:dict(binary(), webql@compiler@reference:return()),
    contexts :: gleam@dict:dict(webql@compiler@reference:supernode(), webql@compiler@context:context())
}).
