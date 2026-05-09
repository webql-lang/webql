import webql/graph
import webql/lang/compiler/hir
import webql/lang/compiler/lowerer/lower_return
import webql/lang/compiler/reference
import webql/lang/compiler/source

pub fn lower_return_test() {
  let return =
    hir.Return(
      name: "out",
      typename: hir.Typename(
        name: "Int",
        reference: reference.Typename(0),
        span: source.Span(start: 8, end: 11),
      ),
      reference: reference.Return(0),
      span: source.Span(start: 3, end: 11),
    )

  assert lower_return.lower(return)
    == graph.Return(name: "out", typename: "Int")
}
