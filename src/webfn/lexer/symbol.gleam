import webfn/lexer/diagnostic
import webfn/lexer/position
import webfn/lexer/token

const single_offset_size = 1

const double_offset_size = 2

/// Tokenizes a symbol by returning a token and offset.
/// If a illegal token is recieved a diagnostic error will be supplied.
pub fn tokenize(
  remaining_bytes: BitArray,
  position: Int,
) -> Result(#(token.Token, BitArray), diagnostic.Diagnostic) {
  case lexeme(remaining_bytes) {
    Ok(#(kind, size, rest_bytes)) -> {
      let token = #(
        token.Token(
          kind:,
          span: position.Span(start: position, end: position + size),
        ),
        rest_bytes,
      )

      Ok(token)
    }

    Error(kind) -> {
      Error(diagnostic.Diagnostic(
        kind:,
        span: position.Span(start: position, end: position),
      ))
    }
  }
}

fn lexeme(bytes: BitArray) {
  case bytes {
    // ========= GROUPINGS =========
    <<"(", rest:bytes>> -> Ok(#(token.LParen, single_offset_size, rest))
    <<")", rest:bytes>> -> Ok(#(token.RParen, single_offset_size, rest))
    <<"{", rest:bytes>> -> Ok(#(token.LBrace, single_offset_size, rest))
    <<"}", rest:bytes>> -> Ok(#(token.RBrace, single_offset_size, rest))
    <<"[", rest:bytes>> -> Ok(#(token.LSquare, single_offset_size, rest))
    <<"]", rest:bytes>> -> Ok(#(token.RSquare, single_offset_size, rest))

    // ======== PUNCTUATION =========
    <<":", rest:bytes>> -> Ok(#(token.Colon, single_offset_size, rest))
    <<",", rest:bytes>> -> Ok(#(token.Comma, single_offset_size, rest))
    <<"=", rest:bytes>> -> Ok(#(token.Equal, single_offset_size, rest))
    <<"->", rest:bytes>> -> Ok(#(token.RArrow, double_offset_size, rest))

    // ========== ILLEGAL ===========
    _illegal_token -> Error(diagnostic.IllegalToken)
  }
}
