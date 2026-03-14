import webfn/lexer/token

const single_grouping_byte_size = 1

/// Tokenizes a grouping or one of (), [], {} by returning a token and offset.
/// If a illegal token is recieved a message with an error will be supplied.
pub fn tokenize(bytes: BitArray) -> Result(#(token.TokenKind, Int), String) {
  case bytes {
    <<"(", _rest:bytes>> -> Ok(#(token.LParen, single_grouping_byte_size))
    <<")", _rest:bytes>> -> Ok(#(token.RParen, single_grouping_byte_size))
    <<"{", _rest:bytes>> -> Ok(#(token.LBrace, single_grouping_byte_size))
    <<"}", _rest:bytes>> -> Ok(#(token.RBrace, single_grouping_byte_size))
    <<"[", _rest:bytes>> -> Ok(#(token.LSquare, single_grouping_byte_size))
    <<"]", _rest:bytes>> -> Ok(#(token.RSquare, single_grouping_byte_size))

    _illegal_token -> Error("Unknown byte recieved while parsing grouping!")
  }
}
