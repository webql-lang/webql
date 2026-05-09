import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_parameter
import webql/lang/compiler/reference
import webql/lang/compiler/source

pub fn lower_parameter_test() {
  let parameter =
    hir.Parameter(
      name: "in",
      typename: hir.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 4, end: 7),
      ),
      reference: reference.Parameter(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_parameter.lower(parameter)
    == graph.Parameter(name: "in", typename: "Int")
}
