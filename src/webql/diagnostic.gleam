import webql/lang/diagnostic as lang_diagnostic
import webql/vm/diagnostic as vm_diagnostic

pub type DiagnosticKind {
  VmDiagnostic(kind: vm_diagnostic.DiagnosticKind)
  LangDiagnostic(kind: lang_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind)
}
