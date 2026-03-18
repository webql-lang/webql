import webql/lexer/position
import webql/lexer/token

/// Lexes upper identifiers.
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_lower_identifier(bytes, start, size)
}

// PRIVATE FUNCTIONS
// =================
fn lex_lower_identifier(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<"a", rest:bytes>>
    | <<"b", rest:bytes>>
    | <<"c", rest:bytes>>
    | <<"d", rest:bytes>>
    | <<"e", rest:bytes>>
    | <<"f", rest:bytes>>
    | <<"g", rest:bytes>>
    | <<"h", rest:bytes>>
    | <<"i", rest:bytes>>
    | <<"j", rest:bytes>>
    | <<"k", rest:bytes>>
    | <<"l", rest:bytes>>
    | <<"m", rest:bytes>>
    | <<"n", rest:bytes>>
    | <<"o", rest:bytes>>
    | <<"p", rest:bytes>>
    | <<"q", rest:bytes>>
    | <<"r", rest:bytes>>
    | <<"s", rest:bytes>>
    | <<"t", rest:bytes>>
    | <<"u", rest:bytes>>
    | <<"v", rest:bytes>>
    | <<"w", rest:bytes>>
    | <<"x", rest:bytes>>
    | <<"y", rest:bytes>>
    | <<"z", rest:bytes>>
    | <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>>
    | <<"_", rest:bytes>> -> {
      lex_lower_identifier(rest, start, size + 1)
    }

    _rest -> {
      let end = start + size

      #(
        token.Token(
          kind: token.LowerIdentifier,
          span: position.Span(start: start, end: end),
        ),
        bytes,
      )
    }
  }
}
