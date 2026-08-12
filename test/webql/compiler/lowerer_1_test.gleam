import webql/compiler/lowerer_1
import webql/compiler/resolver_1
import webql/compiler/source
import webql/graph_1

pub fn lower_ast_test() {
  let identity =
    resolver_1.Ast(
      parameters: [
        resolver_1.Parameter(
          name: "value",
          port: resolver_1.Port("Int"),
          reference: resolver_1.Labeled(["value"]),
          span: span(1),
        ),
      ],
      returns: [
        resolver_1.Return(
          name: "result",
          port: resolver_1.Port("Int"),
          reference: resolver_1.Labeled(["result"]),
          span: span(2),
        ),
      ],
      supernodes: [],
      boundaries: [],
      nodes: [],
      edges: [
        resolver_1.Edge(
          from: resolver_1.Output(
            path: ["value"],
            reference: resolver_1.Labeled(["value"]),
            span: span(3),
          ),
          to: resolver_1.Input(
            path: ["result"],
            reference: resolver_1.Labeled(["result"]),
            span: span(4),
          ),
          reference: resolver_1.Unlabeled(0),
          span: span(5),
        ),
      ],
      span: span(6),
    )

  let empty =
    resolver_1.Ast(
      parameters: [],
      returns: [],
      supernodes: [],
      boundaries: [],
      nodes: [],
      edges: [],
      span: span(7),
    )

  let ast =
    resolver_1.Ast(
      parameters: [
        resolver_1.Parameter(
          name: "token",
          port: resolver_1.Port("Uuid"),
          reference: resolver_1.Labeled(["token"]),
          span: span(8),
        ),
        resolver_1.Parameter(
          name: "left",
          port: resolver_1.Port("Int"),
          reference: resolver_1.Unlabeled(1),
          span: span(9),
        ),
      ],
      returns: [
        resolver_1.Return(
          name: "result",
          port: resolver_1.Port("Int"),
          reference: resolver_1.Labeled(["result"]),
          span: span(10),
        ),
        resolver_1.Return(
          name: "integer",
          port: resolver_1.Port("Int"),
          reference: resolver_1.Labeled(["integer"]),
          span: span(11),
        ),
        resolver_1.Return(
          name: "decimal",
          port: resolver_1.Port("Float"),
          reference: resolver_1.Labeled(["decimal"]),
          span: span(12),
        ),
        resolver_1.Return(
          name: "text",
          port: resolver_1.Port("String"),
          reference: resolver_1.Unlabeled(2),
          span: span(13),
        ),
      ],
      supernodes: [
        resolver_1.Supernode(
          name: "Identity",
          ast: identity,
          reference: resolver_1.Labeled("Identity"),
          span: span(14),
        ),
        resolver_1.Supernode(
          name: "Empty",
          ast: empty,
          reference: resolver_1.Unlabeled(3),
          span: span(15),
        ),
      ],
      boundaries: [
        resolver_1.Boundary(
          name: "service",
          from: resolver_1.Output(
            path: ["token"],
            reference: resolver_1.Labeled(["token"]),
            span: span(16),
          ),
          to: ["Service"],
          reference: resolver_1.Labeled("service"),
          span: span(17),
        ),
        resolver_1.Boundary(
          name: "workflow",
          from: resolver_1.Literal(
            value: resolver_1.String("seed", span: span(18)),
            span: span(19),
          ),
          to: ["service", "Workflow"],
          reference: resolver_1.Unlabeled(4),
          span: span(20),
        ),
      ],
      nodes: [
        resolver_1.Node(
          name: "add",
          path: ["service", "Add"],
          reference: resolver_1.Labeled("add"),
          span: span(21),
        ),
        resolver_1.Node(
          name: "identity",
          path: ["Identity"],
          reference: resolver_1.Unlabeled(5),
          span: span(22),
        ),
      ],
      edges: [
        resolver_1.Edge(
          from: resolver_1.Output(
            path: ["left"],
            reference: resolver_1.Unlabeled(6),
            span: span(23),
          ),
          to: resolver_1.Input(
            path: ["add", "left"],
            reference: resolver_1.Labeled(["add", "left"]),
            span: span(24),
          ),
          reference: resolver_1.Unlabeled(0),
          span: span(25),
        ),
        resolver_1.Edge(
          from: resolver_1.Literal(
            value: resolver_1.Int(42, span: span(26)),
            span: span(27),
          ),
          to: resolver_1.Input(
            path: ["integer"],
            reference: resolver_1.Labeled(["integer"]),
            span: span(28),
          ),
          reference: resolver_1.Unlabeled(1),
          span: span(29),
        ),
        resolver_1.Edge(
          from: resolver_1.Literal(
            value: resolver_1.Float(1.25, span: span(30)),
            span: span(31),
          ),
          to: resolver_1.Input(
            path: ["decimal"],
            reference: resolver_1.Unlabeled(7),
            span: span(32),
          ),
          reference: resolver_1.Unlabeled(2),
          span: span(33),
        ),
        resolver_1.Edge(
          from: resolver_1.Literal(
            value: resolver_1.String("hello", span: span(34)),
            span: span(35),
          ),
          to: resolver_1.Input(
            path: ["text"],
            reference: resolver_1.Labeled(["text"]),
            span: span(36),
          ),
          reference: resolver_1.Unlabeled(3),
          span: span(37),
        ),
      ],
      span: span(38),
    )

  let lowered_identity =
    graph_1.Graph(
      parameters: [
        graph_1.Parameter(name: "value", port: graph_1.Port("Int")),
      ],
      returns: [
        graph_1.Return(name: "result", port: graph_1.Port("Int")),
      ],
      supernodes: [],
      boundaries: [],
      nodes: [],
      edges: [
        graph_1.Edge(
          from: graph_1.Output(path: ["value"]),
          to: graph_1.Input(path: ["result"]),
        ),
      ],
    )

  let lowered_empty =
    graph_1.Graph(
      parameters: [],
      returns: [],
      supernodes: [],
      boundaries: [],
      nodes: [],
      edges: [],
    )

  assert lowerer_1.lower(ast)
    == graph_1.Graph(
      parameters: [
        graph_1.Parameter(name: "token", port: graph_1.Port("Uuid")),
        graph_1.Parameter(name: "left", port: graph_1.Port("Int")),
      ],
      returns: [
        graph_1.Return(name: "result", port: graph_1.Port("Int")),
        graph_1.Return(name: "integer", port: graph_1.Port("Int")),
        graph_1.Return(name: "decimal", port: graph_1.Port("Float")),
        graph_1.Return(name: "text", port: graph_1.Port("String")),
      ],
      supernodes: [
        graph_1.Supernode(name: "Identity", graph: lowered_identity),
        graph_1.Supernode(name: "Empty", graph: lowered_empty),
      ],
      boundaries: [
        graph_1.Boundary(
          name: "service",
          from: graph_1.Output(path: ["token"]),
          to: ["Service"],
        ),
        graph_1.Boundary(
          name: "workflow",
          from: graph_1.Literal(value: graph_1.String("seed")),
          to: ["service", "Workflow"],
        ),
      ],
      nodes: [
        graph_1.Node(name: "add", path: ["service", "Add"]),
        graph_1.Node(name: "identity", path: ["Identity"]),
      ],
      edges: [
        graph_1.Edge(
          from: graph_1.Output(path: ["left"]),
          to: graph_1.Input(path: ["add", "left"]),
        ),
        graph_1.Edge(
          from: graph_1.Literal(value: graph_1.Int(42)),
          to: graph_1.Input(path: ["integer"]),
        ),
        graph_1.Edge(
          from: graph_1.Literal(value: graph_1.Float(1.25)),
          to: graph_1.Input(path: ["decimal"]),
        ),
        graph_1.Edge(
          from: graph_1.Literal(value: graph_1.String("hello")),
          to: graph_1.Input(path: ["text"]),
        ),
      ],
    )
}

fn span(start: Int) -> source.Span {
  source.Span(start:, end: start + 1)
}
