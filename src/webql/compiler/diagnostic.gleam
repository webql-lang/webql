import webql/compiler/lexer
import webql/compiler/parser
import webql/compiler/resolver
import webql/compiler/typechecker

import webql/compiler/source

pub type DiagnosticKind {
  LexerDiagnostic(kind: lexer.DiagnosticKind)
  ParserDiagnostic(kind: parser.DiagnosticKind)
  ResolverDiagnostic(kind: resolver.DiagnosticKind)
  TypecheckerDiagnostic(kind: typechecker.DiagnosticKind)
}

pub type Diagnostic {
  Diagnostic(kind: DiagnosticKind, span: source.Span)
}
