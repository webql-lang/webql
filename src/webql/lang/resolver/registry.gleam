import gleam/dict
import gleam/list
import webql/lang/resolver/reference

/// The environment is a key-value store that gets populated as the language resolves foreign references.
pub type Environment {
  Environment
}

/// The catalog is a key-value store initialized when the registry is created.
/// This is designed to hold static records for the type-checker to discover.
pub type Catalog {
  Catalog(typenames: dict.Dict(String, reference.Type))
}

/// A incrementing generator designed to store the next unique stable ID.
pub type Generator {
  Generator(typenames: Int)
}

/// A registry with resolver context and a stable ID generator.
pub type Registry {
  Registry(generator: Generator, catalog: Catalog, environment: Environment)
}

/// Creates a registry with a catalog of typenames.
pub fn new(typenames typenames: List(String)) -> Registry {
  let registry =
    Registry(
      generator: Generator(typenames: 0),
      catalog: Catalog(typenames: dict.new()),
      environment: Environment,
    )

  register_typenames(registry, typenames:)
}

// PRIVATE FUNCTIONS
// =================
fn register_typenames(registry: Registry, typenames typenames: List(String)) {
  list.fold(typenames, registry, fn(registry, typename) {
    let Registry(generator:, catalog:, ..) = registry
    let Generator(typenames: count) = generator

    case dict.get(catalog.typenames, typename) {
      Ok(_) -> registry
      Error(_empty) ->
        Registry(
          ..registry,
          generator: Generator(typenames: count + 1),
          catalog: Catalog(typenames: dict.insert(
            catalog.typenames,
            typename,
            reference.Type(count),
          )),
        )
    }
  })
}
