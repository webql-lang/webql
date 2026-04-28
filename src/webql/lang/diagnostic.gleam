import webql/lang/compiler/diagnostic as compiler_diagnostic
import webql/lang/loader/diagnostic as loader_diagnostic

pub type DiagnosticKind {
  LoaderError(kind: loader_diagnostic.DiagnosticKind)
  CompilerError(kind: compiler_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
