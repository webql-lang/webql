import webql/compiler/lowerer/lower_parameter
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_parameter_test() {
  let parameter =
    hir.Parameter(
      name: "in",
      port: hir.Port(
        name: "Int",
        reference: reference.Port(0),
        span: source.Span(start: 4, end: 7),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_parameter.lower(parameter)
    == graph.Parameter(name: "in", port: "Int")
}
