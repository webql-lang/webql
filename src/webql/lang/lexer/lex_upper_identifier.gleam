import webql/lang/lexer/token
import webql/lang/source

/// Lexes upper identifiers.
pub fn lex(bytes: BitArray, start: Int, size: Int) -> #(token.Token, BitArray) {
  lex_upper_identifier(bytes, start, size)
}

// PRIVATE FUNCTIONS
// =================
fn lex_upper_identifier(bytes: BitArray, start: Int, size: Int) {
  case bytes {
    <<"A", rest:bytes>>
    | <<"B", rest:bytes>>
    | <<"C", rest:bytes>>
    | <<"D", rest:bytes>>
    | <<"E", rest:bytes>>
    | <<"F", rest:bytes>>
    | <<"G", rest:bytes>>
    | <<"H", rest:bytes>>
    | <<"I", rest:bytes>>
    | <<"J", rest:bytes>>
    | <<"K", rest:bytes>>
    | <<"L", rest:bytes>>
    | <<"M", rest:bytes>>
    | <<"N", rest:bytes>>
    | <<"O", rest:bytes>>
    | <<"P", rest:bytes>>
    | <<"Q", rest:bytes>>
    | <<"R", rest:bytes>>
    | <<"S", rest:bytes>>
    | <<"T", rest:bytes>>
    | <<"U", rest:bytes>>
    | <<"V", rest:bytes>>
    | <<"W", rest:bytes>>
    | <<"X", rest:bytes>>
    | <<"Y", rest:bytes>>
    | <<"Z", rest:bytes>>
    | <<"a", rest:bytes>>
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
    | <<"9", rest:bytes>> -> {
      lex_upper_identifier(rest, start, size + 1)
    }

    _rest -> {
      let end = start + size

      #(
        token.Token(
          kind: token.UpperIdentifier,
          span: source.Span(start: start, end: end),
        ),
        bytes,
      )
    }
  }
}
