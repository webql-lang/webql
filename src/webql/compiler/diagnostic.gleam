import webql/compiler/lexer/diagnostic as lexer_diagnostic
import webql/compiler/parser/diagnostic as parser_diagnostic
import webql/compiler/resolver/diagnostic as resolver_diagnostic
import webql/compiler/typechecker/diagnostic as typechecker_diagnostic

import webql/compiler/source

pub type DiagnosticKind {
  LexerDiagnostic(kind: lexer_diagnostic.DiagnosticKind)
  ParserDiagnostic(kind: parser_diagnostic.DiagnosticKind)
  ResolverDiagnostic(kind: resolver_diagnostic.DiagnosticKind)
  TypecheckerDiagnostic(kind: typechecker_diagnostic.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
