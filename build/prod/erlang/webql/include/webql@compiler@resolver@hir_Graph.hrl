-record(graph, {
    parameters :: list(webql@compiler@resolver@hir:parameter()),
    returns :: list(webql@compiler@resolver@hir:return()),
    nodes :: list(webql@compiler@resolver@hir:node_()),
    edges :: list(webql@compiler@resolver@hir:edge()),
    span :: webql@compiler@source:span()
}).
