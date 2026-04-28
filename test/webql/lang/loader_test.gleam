import gleam/dict
import webql/lang/compiler/reference
import webql/lang/loader
import webql/lang/loader/preschema
import webql/lang/loader/schema

pub fn load_creates_schema_from_typenames_and_nodes_test() {
  assert loader.load(
      preschema.Preschema(typenames: ["Int"], nodes: [
        #("Node", [#("input", "Int")], [#("output", "Int")]),
      ]),
    )
    == schema.Schema(
      typenames: dict.from_list([#("Int", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.from_list([
        #(reference.Node(0), [#("input", reference.Typename(0))]),
      ]),
      outputs: dict.from_list([
        #(reference.Node(0), [#("output", reference.Typename(0))]),
      ]),
    )
}

pub fn load_uses_next_typename_for_unknown_input_typename_test() {
  assert loader.load(
      preschema.Preschema(typenames: ["Int"], nodes: [
        #("Node", [#("input", "String")], []),
      ]),
    )
    == schema.Schema(
      typenames: dict.from_list([#("Int", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.from_list([
        #(reference.Node(0), [#("input", reference.Typename(1))]),
      ]),
      outputs: dict.new(),
    )
}

pub fn load_uses_next_typename_for_unknown_output_typename_test() {
  assert loader.load(
      preschema.Preschema(typenames: ["Int"], nodes: [
        #("Node", [], [#("output", "String")]),
      ]),
    )
    == schema.Schema(
      typenames: dict.from_list([#("Int", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.new(),
      outputs: dict.from_list([
        #(reference.Node(0), [#("output", reference.Typename(1))]),
      ]),
    )
}
