import gleam/dict
import webql/introspection/schema
import webql/lang/compiler/bootstrap
import webql/lang/compiler/environment
import webql/lang/compiler/reference

pub fn load_creates_environment_from_spec_test() {
  assert bootstrap.bootstrap(
      schema.Schema(
        operators: dict.from_list([
          #(
            "Node",
            schema.Operator(
              name: "Node",
              inputs: [schema.Input(name: "input", typename: "Int")],
              outputs: [schema.Output(name: "output", typename: "Int")],
            ),
          ),
        ]),
      ),
    )
    == environment.Environment(
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

pub fn load_registers_input_typenames_from_spec_test() {
  assert bootstrap.bootstrap(
      schema.Schema(
        operators: dict.from_list([
          #(
            "Node",
            schema.Operator(
              name: "Node",
              inputs: [schema.Input(name: "input", typename: "String")],
              outputs: [],
            ),
          ),
        ]),
      ),
    )
    == environment.Environment(
      typenames: dict.from_list([#("String", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.from_list([
        #(reference.Node(0), [#("input", reference.Typename(0))]),
      ]),
      outputs: dict.new(),
    )
}

pub fn load_registers_output_typenames_from_spec_test() {
  assert bootstrap.bootstrap(
      schema.Schema(
        operators: dict.from_list([
          #(
            "Node",
            schema.Operator(name: "Node", inputs: [], outputs: [
              schema.Output(name: "output", typename: "String"),
            ]),
          ),
        ]),
      ),
    )
    == environment.Environment(
      typenames: dict.from_list([#("String", reference.Typename(0))]),
      nodes: dict.from_list([#("Node", reference.Node(0))]),
      inputs: dict.new(),
      outputs: dict.from_list([
        #(reference.Node(0), [#("output", reference.Typename(0))]),
      ]),
    )
}
