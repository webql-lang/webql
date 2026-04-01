import gleam/dict
import webql/lang/resolver/reference

pub type Environment {
  Environment(typenames: dict.Dict(String, reference.Type))
}

/// Creates a new environment with a list of typenames.
pub fn new(typenames: dict.Dict(String, reference.Type)) -> Environment {
  Environment(typenames:)
}
