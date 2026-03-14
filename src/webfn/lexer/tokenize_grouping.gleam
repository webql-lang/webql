import webfn/lexer/token

/// Tokenizes a grouping or one of (), [], {}
/// If a illegal token is recieved, this will raise!
pub fn tokenize(bytes: BitArray) -> token.TokenKind {
  case bytes {
    <<"(", _rest:bytes>> -> token.LParen
    <<")", _rest:bytes>> -> token.RParen
    <<"{", _rest:bytes>> -> token.LBrace
    <<"}", _rest:bytes>> -> token.RBrace
    <<"[", _rest:bytes>> -> token.LSquare
    <<"]", _rest:bytes>> -> token.RSquare

    _illegal_token -> panic as "Unknown byte recieved while parsing a grouping!"
  }
}
