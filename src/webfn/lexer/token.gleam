import webfn/lexer/position

pub type TokenKind {
  // ========== LITERALS ==========
  Name
  Int
  Float
  String
  Bool
  CommentSingle
  CommentMulti

  // ========= GROUPINGS ==========
  LParen
  RParen
  LBrace
  RBrace
  LSquare
  RSquare

  // ======== PUNCTUATION =========
  Colon
  Comma
  Equal
  RArrow

  // ========== SPACING ===========
  Space
  EOF
}

pub type Token {
  Token(kind: TokenKind, span: position.Span)
}
