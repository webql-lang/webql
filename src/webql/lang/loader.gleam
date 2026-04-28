import webql/lang/loader/preschema
import webql/lang/loader/schema

/// Loads preschema as a schema.
pub fn load(preschema: preschema.Preschema) -> schema.Schema {
  preschema.load(preschema)
}
