import gleam/dict
import webql/lang/resolver/reference
import webql/lang/resolver/registry

pub fn new_returns_empty_registry_when_typenames_and_nodes_are_empty_test() {
  let registry = registry.new([], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(
    typenames: typenames_count,
    nodes: nodes_count,
    accesses: accesses_count,
    operations: operations_count,
    bindings: bindings_count,
  ) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(inputs:, outputs:, operations:) = environment

  assert typenames_count == 0
  assert nodes_count == 0
  assert accesses_count == 0
  assert operations_count == 0
  assert bindings_count == 0
  assert typenames == dict.new()
  assert nodes == dict.new()
  assert inputs == dict.new()
  assert outputs == dict.new()
  assert operations == dict.new()
}

pub fn new_registers_a_single_typename_test() {
  let registry = registry.new(["Int"], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 1
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
    ])
  assert nodes == dict.new()
}

pub fn new_registers_multiple_typenames_in_order_test() {
  let registry = registry.new(["Int", "String", "Bool"], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 3
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
      #("Bool", reference.Typename(2)),
    ])
  assert nodes == dict.new()
}

pub fn new_skips_duplicate_typenames_test() {
  let registry = registry.new(["Int", "String", "Int", "String"], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 2
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
    ])
  assert nodes == dict.new()
}

pub fn new_preserves_first_reference_when_duplicates_are_present_test() {
  let registry = registry.new(["Int", "String", "Int", "Bool"], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 3
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
      #("Bool", reference.Typename(2)),
    ])
  assert nodes == dict.new()
}

pub fn new_registers_non_consecutive_duplicates_correctly_test() {
  let registry =
    registry.new(["Int", "String", "Bool", "String", "Int", "Float"], [])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 4
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
      #("Bool", reference.Typename(2)),
      #("Float", reference.Typename(3)),
    ])
  assert nodes == dict.new()
}

pub fn new_registers_a_single_node_test() {
  let registry = registry.new([], ["Math"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(nodes: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 1
  assert typenames == dict.new()
  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
    ])
}

pub fn new_registers_multiple_nodes_in_order_test() {
  let registry = registry.new([], ["Math", "Filter", "Map"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(nodes: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 3
  assert typenames == dict.new()
  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Filter", reference.Node(1)),
      #("Map", reference.Node(2)),
    ])
}

pub fn new_skips_duplicate_nodes_test() {
  let registry = registry.new([], ["Math", "Filter", "Math", "Filter"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(nodes: count, ..) = generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(..) = environment

  assert count == 2
  assert typenames == dict.new()
  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Filter", reference.Node(1)),
    ])
}

pub fn new_registers_typenames_and_nodes_together_test() {
  let registry = registry.new(["Int", "String"], ["Math", "Map"])

  let registry.Registry(generator:, catalog:, environment:) = registry
  let registry.Generator(typenames: typenames_count, nodes: nodes_count, ..) =
    generator
  let registry.Catalog(typenames:, nodes:) = catalog
  let registry.Environment(inputs:, outputs:, operations:) = environment

  assert typenames_count == 2
  assert nodes_count == 2
  assert typenames
    == dict.from_list([
      #("Int", reference.Typename(0)),
      #("String", reference.Typename(1)),
    ])
  assert nodes
    == dict.from_list([
      #("Math", reference.Node(0)),
      #("Map", reference.Node(1)),
    ])
  assert inputs == dict.new()
  assert outputs == dict.new()
  assert operations == dict.new()
}
