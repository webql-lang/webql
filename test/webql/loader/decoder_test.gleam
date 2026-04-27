import gleam/dynamic
import gleam/dynamic/decode as dynamic_decode
import webql/loader/decoder

pub fn decode_decodes_ports_from_dynamic_records_test() {
  let using = decoder.decode(decode)
  let document =
    dynamic.properties([
      #(
        dynamic.string("typenames"),
        dynamic.list([dynamic.string("Int"), dynamic.string("String")]),
      ),
      #(
        dynamic.string("nodes"),
        dynamic.list([
          dynamic.properties([
            #(dynamic.string("name"), dynamic.string("Node")),
            #(
              dynamic.string("inputs"),
              dynamic.list([
                dynamic.properties([
                  #(dynamic.string("name"), dynamic.string("in")),
                  #(dynamic.string("typename"), dynamic.string("Int")),
                ]),
              ]),
            ),
            #(
              dynamic.string("outputs"),
              dynamic.list([
                dynamic.properties([
                  #(dynamic.string("name"), dynamic.string("out")),
                  #(dynamic.string("typename"), dynamic.string("String")),
                ]),
              ]),
            ),
          ]),
        ]),
      ),
    ])

  assert dynamic_decode.run(document, using)
    == Ok(
      #(
        [
          "Int",
          "String",
        ],
        [
          #("Node", [#("in", "Int")], [#("out", "String")]),
        ],
      ),
    )
}

pub fn decode_rejects_dynamic_key_mismatch_test() {
  let using = decoder.decode(decode)
  let document =
    dynamic.properties([
      #(dynamic.string("incorrect_key"), dynamic.list([])),
    ])

  let assert Error(_) = dynamic_decode.run(document, using)
}

fn decode(typenames, nodes) {
  #(typenames, nodes)
}
