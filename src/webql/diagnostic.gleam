import webql/engine/diagnostic as engine_diagnostic
import webql/lang/diagnostic as lang_diagnostic

pub type DiagnosticKind {
  EngineDiagnostic(kind: engine_diagnostic.DiagnosticKind)
  LangDiagnostic(kind: lang_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
