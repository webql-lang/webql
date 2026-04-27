import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode as dynamic_decode
import webql/compiler/reference
import webql/loader
import webql/loader/schema

pub fn load_decodes_dynamic_data_test() {
  assert loader.load(dynamic_schema()) == Ok(schema())
}

pub fn decoder_decodes_dynamic_data_test() {
  assert dynamic_decode.run(dynamic_schema(), loader.decoder()) == Ok(schema())
}

fn dynamic_schema() {
  dynamic.properties([
    #(dynamic.string("typenames"), dynamic.list([dynamic.string("Int")])),
    #(
      dynamic.string("nodes"),
      dynamic.list([
        dynamic.properties([
          #(dynamic.string("name"), dynamic.string("Node")),
          #(
            dynamic.string("inputs"),
            dynamic.list([
              dynamic.properties([
                #(dynamic.string("name"), dynamic.string("value")),
                #(dynamic.string("typename"), dynamic.string("Int")),
              ]),
            ]),
          ),
          #(
            dynamic.string("outputs"),
            dynamic.list([
              dynamic.properties([
                #(dynamic.string("name"), dynamic.string("value")),
                #(dynamic.string("typename"), dynamic.string("Int")),
              ]),
            ]),
          ),
        ]),
      ]),
    ),
  ])
}

fn schema() {
  schema.Schema(
    typenames: dict.from_list([#("Int", reference.Typename(0))]),
    nodes: dict.from_list([#("Node", reference.Node(0))]),
    inputs: dict.from_list([
      #(reference.Node(0), [#("value", reference.Typename(0))]),
    ]),
    outputs: dict.from_list([
      #(reference.Node(0), [#("value", reference.Typename(0))]),
    ]),
  )
}
