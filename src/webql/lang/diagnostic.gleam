import webql/lang/compiler/diagnostic as compiler_diagnostic

pub type DiagnosticKind {
  CompilerDiagnostic(kind: compiler_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
