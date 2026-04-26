import webql/compiler
import webql/loader

pub fn main() {
  let loader = loader.new()
  let assert Ok(schema) =
    loader.load(
      loader,
      "{\"typenames\": [\"Int\", \"String\"], \"nodes\": [{\"name\": \"Math\", \"inputs\": [{ \"name\": \"l\", \"typename\": \"Int\" },{ \"name\": \"r\", \"typename\": \"Int\" }],\"outputs\": [{ \"name\": \"value\", \"typename\": \"Int\" }]}, {\"name\": \"ToInt\", \"inputs\": [{ \"name\": \"value\", \"typename\": \"String\" }],\"outputs\": [{ \"name\": \"value\", \"typename\": \"Int\" }]}]}",
    )

  let compiler = compiler.new(schema)

  echo compiler.compile(
    compiler,
    "
  in: Int -> out: Int {
    m = Math
    value = 12

    value -> m.l
    .in -> m.r

    m.value -> .out
  }
  ",
  )
}
