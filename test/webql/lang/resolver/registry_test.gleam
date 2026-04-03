import gleam/dict
import webql/lang/resolver/reference
import webql/lang/resolver/registry

pub fn new_returns_empty_registry_when_typenames_are_empty_test() {
  let registry = registry.new([])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 0
  assert typenames == dict.new()
}

pub fn new_registers_a_single_typename_test() {
  let registry = registry.new(["Int"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 1
  assert typenames
    == dict.from_list([
      #("Int", reference.Type(0)),
    ])
}

pub fn new_registers_multiple_typenames_in_order_test() {
  let registry = registry.new(["Int", "String", "Boolean"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 3
  assert typenames
    == dict.from_list([
      #("Int", reference.Type(0)),
      #("String", reference.Type(1)),
      #("Boolean", reference.Type(2)),
    ])
}

pub fn new_skips_duplicate_typenames_test() {
  let registry = registry.new(["Int", "String", "Int", "String"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 2
  assert typenames
    == dict.from_list([
      #("Int", reference.Type(0)),
      #("String", reference.Type(1)),
    ])
}

pub fn new_preserves_first_reference_when_duplicates_are_present_test() {
  let registry = registry.new(["Int", "String", "Int", "Boolean"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 3
  assert typenames
    == dict.from_list([
      #("Int", reference.Type(0)),
      #("String", reference.Type(1)),
      #("Boolean", reference.Type(2)),
    ])
}

pub fn new_registers_non_consecutive_duplicates_correctly_test() {
  let registry =
    registry.new(["Int", "String", "Boolean", "String", "Int", "Float"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count) = generator
  let registry.Catalog(typenames: typenames) = catalog
  let registry.Environment = environment

  assert count == 4
  assert typenames
    == dict.from_list([
      #("Int", reference.Type(0)),
      #("String", reference.Type(1)),
      #("Boolean", reference.Type(2)),
      #("Float", reference.Type(3)),
    ])
}
