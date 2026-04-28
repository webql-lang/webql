import webql/graph
import webql/lang
import webql/lang/diagnostic
import webql/lang/loader/blueprint

/// Compiles a WebQL source file with a blueprint.
pub fn compile(
  source: String,
  blueprint: blueprint.Blueprint,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  lang.compile(source, blueprint)
}
