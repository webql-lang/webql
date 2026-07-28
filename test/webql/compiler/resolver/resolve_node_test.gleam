import webql/compiler/context
import webql/compiler/environment
import webql/compiler/parser
import webql/compiler/reference
import webql/compiler/resolver/diagnostic
import webql/compiler/resolver/hir
import webql/compiler/resolver/resolve_graph
import webql/compiler/resolver/resolve_node
import webql/compiler/source

pub fn resolve_node_test() {
  let schema = environment.add_node(environment.new(), "Math")

  let node_to_resolve =
    parser.Node(
      name: "math",
      node: "Math",
      span: source.Span(start: 0, end: 11),
    )

  let assert Ok(#(node, _context, _environment)) =
    resolve_node.resolve(
      schema,
      context.new(),
      node_to_resolve,
      resolve_graph.resolve,
    )

  assert node
    == hir.Node(
      name: "math",
      node: "Math",
      reference: reference.Node(0),
      span: source.Span(start: 0, end: 11),
    )
}

pub fn resolve_returns_duplicate_node_for_existing_node_test() {
  let context = context.add_node(context.new(), "math")

  let node_to_resolve =
    parser.Node(
      name: "math",
      node: "Math",
      span: source.Span(start: 0, end: 11),
    )

  let assert Error(error) =
    resolve_node.resolve(
      environment.new(),
      context,
      node_to_resolve,
      resolve_graph.resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateNode("math"),
      span: source.Span(start: 0, end: 11),
    )
}

pub fn resolve_node_resolves_supernode_test() {
  let schema = environment.add_port(environment.new(), "Int")

  let supernode_to_resolve =
    parser.Supernode(
      name: "Inner",
      graph: parser.Graph(
        parameters: [
          parser.Parameter(
            name: "in",
            port: parser.Port(
              name: "Int",
              span: source.Span(start: 15, end: 18),
            ),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          parser.Return(
            name: "out",
            port: parser.Port(
              name: "Int",
              span: source.Span(start: 27, end: 30),
            ),
            span: source.Span(start: 22, end: 30),
          ),
        ],
        nodes: [],
        edges: [
          parser.Edge(
            source: parser.Output(
              path: ["in"],
              span: source.Span(start: 34, end: 37),
            ),
            target: parser.Input(
              path: ["out"],
              span: source.Span(start: 41, end: 45),
            ),
            span: source.Span(start: 34, end: 45),
          ),
        ],
        span: source.Span(start: 8, end: 47),
      ),
      span: source.Span(start: 0, end: 47),
    )

  let assert Ok(#(supernode, _context, _environment)) =
    resolve_node.resolve(
      schema,
      context.new(),
      supernode_to_resolve,
      resolve_graph.resolve,
    )

  assert supernode
    == hir.Supernode(
      name: "Inner",
      graph: hir.Graph(
        parameters: [
          hir.Parameter(
            name: "in",
            port: hir.Port(
              name: "Int",
              reference: reference.Port(0),
              span: source.Span(start: 15, end: 18),
            ),
            reference: reference.Parameter(0),
            span: source.Span(start: 11, end: 18),
          ),
        ],
        returns: [
          hir.Return(
            name: "out",
            port: hir.Port(
              name: "Int",
              reference: reference.Port(0),
              span: source.Span(start: 27, end: 30),
            ),
            reference: reference.Return(0),
            span: source.Span(start: 22, end: 30),
          ),
        ],
        nodes: [],
        edges: [
          hir.Edge(
            source: hir.Output(
              path: ["in"],
              reference: reference.Output(0),
              span: source.Span(start: 34, end: 37),
            ),
            target: hir.Input(
              path: ["out"],
              reference: reference.Input(0),
              span: source.Span(start: 41, end: 45),
            ),
            reference: reference.Edge(0),
            span: source.Span(start: 34, end: 45),
          ),
        ],
        span: source.Span(start: 8, end: 47),
      ),
      reference: reference.Supernode(0),
      span: source.Span(start: 0, end: 47),
    )
}

pub fn resolve_node_returns_duplicate_supernode_test() {
  let schema = environment.add_node(environment.new(), "Inner")

  let supernode_to_resolve =
    parser.Supernode(
      name: "Inner",
      graph: parser.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
        span: source.Span(start: 8, end: 10),
      ),
      span: source.Span(start: 0, end: 10),
    )

  let assert Error(error) =
    resolve_node.resolve(
      schema,
      context.new(),
      supernode_to_resolve,
      resolve_graph.resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateSupernode("Inner"),
      span: source.Span(start: 0, end: 10),
    )
}

pub fn resolve_node_returns_duplicate_supernode_for_schema_node_test() {
  let schema = environment.add_node(environment.new(), "Math")

  let supernode_to_resolve =
    parser.Supernode(
      name: "Math",
      graph: parser.Graph(
        parameters: [],
        returns: [],
        nodes: [],
        edges: [],
        span: source.Span(start: 7, end: 9),
      ),
      span: source.Span(start: 0, end: 9),
    )

  let assert Error(error) =
    resolve_node.resolve(
      schema,
      context.new(),
      supernode_to_resolve,
      resolve_graph.resolve,
    )

  assert error
    == diagnostic.Diagnostic(
      kind: diagnostic.DuplicateSupernode("Math"),
      span: source.Span(start: 0, end: 9),
    )
}
