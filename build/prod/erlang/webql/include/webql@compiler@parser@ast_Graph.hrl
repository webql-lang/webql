-record(graph, {
    parameters :: list(webql@compiler@parser@ast:parameter()),
    returns :: list(webql@compiler@parser@ast:return()),
    nodes :: list(webql@compiler@parser@ast:node_()),
    edges :: list(webql@compiler@parser@ast:edge()),
    span :: webql@compiler@source:span()
}).
