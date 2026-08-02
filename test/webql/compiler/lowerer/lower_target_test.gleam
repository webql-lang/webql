import webql/compiler/lowerer/lower_target
import webql/compiler/reference
import webql/compiler/resolver
import webql/compiler/source
import webql/graph

pub fn lower_target_lowers_single_element_path_test() {
  let input =
    resolver.Input(
      path: ["value"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 5),
    )

  assert lower_target.lower(input) == graph.Input(path: ["value"])
}

pub fn lower_target_lowers_multi_part_path_test() {
  let input =
    resolver.Input(
      path: ["user", "id"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 7),
    )

  assert lower_target.lower(input) == graph.Input(path: ["user", "id"])
}

pub fn lower_target_preserves_path_length_test() {
  let input =
    resolver.Input(
      path: ["a", "b", "c"],
      reference: reference.Input(0),
      span: source.Span(start: 0, end: 5),
    )

  assert lower_target.lower(input) == graph.Input(path: ["a", "b", "c"])
}
