import webql/compiler/lowerer/lower_input
import webql/compiler/reference
import webql/compiler/resolver/hir
import webql/compiler/source
import webql/graph

pub fn lower_input_lowers_single_element_path_test() {
  let input =
    hir.PortInput(
      path: ["value"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 5),
    )

  assert lower_input.lower(input) == graph.Input(path: ["value"])
}

pub fn lower_input_lowers_multi_part_path_test() {
  let input =
    hir.PortInput(
      path: ["user", "id"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_input.lower(input) == graph.Input(path: ["user", "id"])
}

pub fn lower_input_preserves_path_length_test() {
  let input =
    hir.PortInput(
      path: ["a", "b", "c"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 5),
    )

  assert lower_input.lower(input) == graph.Input(path: ["a", "b", "c"])
}
