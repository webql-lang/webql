import webql/lang/compiler/diagnostic as compiler_diagnostic

pub type DiagnosticKind {
  CompilerError(kind: compiler_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
