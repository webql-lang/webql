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
    SubO = in: String -> out: Int {
      SubO = in: String -> out: Int { # lint rule one no shadow!
        ti = ToInt
        ti2 = ToInt # lint rule two unused references!
        .in -> ti.value
        ti.value -> .out
      }

      so = SubO

      .in -> so.in
      so.out -> .out
    }

    so = SubO

    \"123\" -> so.in
    so.out -> m.l
    .in -> m.r

    m.value -> .out
  }
  ",
  )
}
