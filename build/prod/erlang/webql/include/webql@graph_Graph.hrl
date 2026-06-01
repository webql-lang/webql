-record(graph, {
    parameters :: list(webql@graph:parameter()),
    returns :: list(webql@graph:return()),
    nodes :: list(webql@graph:node_()),
    edges :: list(webql@graph:edge())
}).
