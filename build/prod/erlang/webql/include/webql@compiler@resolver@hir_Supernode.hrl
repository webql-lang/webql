-record(supernode, {
    name :: binary(),
    graph :: webql@compiler@resolver@hir:graph(),
    reference :: webql@compiler@reference:supernode(),
    span :: webql@compiler@source:span()
}).
