-record(node, {
    name :: binary(),
    node :: binary(),
    operation :: webql@compiler@reference:operation(),
    reference :: webql@compiler@reference:node_(),
    span :: webql@compiler@source:span()
}).
