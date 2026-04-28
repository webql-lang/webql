import webql/graph
import webql/lang
import webql/lang/diagnostic
import webql/lang/loader/preschema

/// Compiles a WebQL source file with a preschema.
pub fn compile(
  source: String,
  preschema: preschema.Preschema,
) -> Result(graph.Module, diagnostic.Diagnostic) {
  lang.compile(source, preschema)
}
