import webql/lang/diagnostic as lang_diagnostic
import webql/runtime/engine/diagnostic as runtime_diagnostic

pub type DiagnosticKind {
  RuntimeDiagnostic(kind: runtime_diagnostic.DiagnosticKind)
  LangDiagnostic(kind: lang_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
