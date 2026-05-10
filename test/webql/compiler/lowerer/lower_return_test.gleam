import webql/compiler/lowerer/lower_return
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

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
