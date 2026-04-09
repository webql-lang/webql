import gleam/dict
import gleam/list
import gleam/option
import webql/lang/resolver/reference

/// The environment is a key-value store that gets populated as the language resolves foreign references.
pub type Environment {
  Environment(
    inputs: dict.Dict(#(option.Option(String), String), reference.Port),
    outputs: dict.Dict(#(option.Option(String), String), reference.Port),
    operations: dict.Dict(String, #(reference.Operation, Environment)),
  )
}

/// The catalog is a key-value store initialized when the registry is created.
/// This is designed to hold static records for the type-checker to discover.
pub type Catalog {
  Catalog(
    typenames: dict.Dict(String, reference.Type),
    nodes: dict.Dict(String, reference.Node),
  )
}

/// A incrementing generator designed to store the next unique stable ID.
pub type Generator {
  Generator(typenames: Int, nodes: Int, ports: Int, operations: Int)
}

/// A registry with resolver context and a stable ID generator.
pub type Registry {
  Registry(generator: Generator, catalog: Catalog, environment: Environment)
}

/// Creates a registry with a catalog of typenames.
pub fn new(
  typenames typenames: List(String),
  nodes nodes: List(String),
) -> Registry {
  let registry =
    Registry(
      catalog: Catalog(typenames: dict.new(), nodes: dict.new()),
      generator: Generator(typenames: 0, nodes: 0, ports: 0, operations: 0),
      environment: Environment(
        inputs: dict.new(),
        outputs: dict.new(),
        operations: dict.new(),
      ),
    )

  registry
  |> register_typenames(typenames)
  |> register_nodes(nodes)
}

// PRIVATE FUNCTIONS
// =================
fn register_typenames(registry: Registry, typenames: List(String)) {
  list.fold(typenames, registry, fn(registry, typename) {
    let Registry(generator:, catalog:, ..) = registry
    let Generator(typenames: count, ..) = generator

    case dict.get(catalog.typenames, typename) {
      Ok(_) -> registry
      Error(_empty) ->
        Registry(
          ..registry,
          generator: Generator(..generator, typenames: count + 1),
          catalog: Catalog(
            ..catalog,
            typenames: dict.insert(
              catalog.typenames,
              typename,
              reference.Type(count),
            ),
          ),
        )
    }
  })
}

fn register_nodes(registry: Registry, nodes: List(String)) {
  list.fold(nodes, registry, fn(registry, node) {
    let Registry(generator:, catalog:, ..) = registry
    let Generator(nodes: count, ..) = generator

    case dict.get(catalog.nodes, node) {
      Ok(_) -> registry
      Error(_empty) ->
        Registry(
          ..registry,
          generator: Generator(..generator, nodes: count + 1),
          catalog: Catalog(
            ..catalog,
            nodes: dict.insert(catalog.nodes, node, reference.Node(count)),
          ),
        )
    }
  })
}
