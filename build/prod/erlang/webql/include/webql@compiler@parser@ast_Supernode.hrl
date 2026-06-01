-record(supernode, {
    name :: binary(),
    graph :: webql@compiler@parser@ast:graph(),
    span :: webql@compiler@source:span()
}).
