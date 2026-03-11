import gleam/bit_array
import gleam/list
import webfn/lexer/token
import webfn/lexer/tokenize_number

pub type LexerMode {
  Normal
}

pub opaque type Lexer {
  Lexer(
    /// The original source provided when instantiating the lexer. This remains unchanged throughout the lexing process.
    source: String,
    /// The original source converted to a `BitArray`.
    bytes: BitArray,
    /// The remaining source to process.
    remaining_bytes: BitArray,
    /// The current byte position from the start of the source.
    position: Int,
    /// The current mode the lexer is parsing code in
    mode: LexerMode,
  )
}

/// Creates a new lexer instance from a utf8 source
pub fn new(source: String) -> Lexer {
  let bytes = bit_array.from_string(source)

  Lexer(
    source: source,
    remaining_bytes: bytes,
    bytes:,
    position: 0,
    mode: Normal,
  )
}

/// Takes a lexer source and converts it to a list of tokens.
pub fn run(lexer: Lexer) -> List(token.Token) {
  let tokens = []

  lexer
  |> tokenize(tokens)
  |> list.reverse()
}

// ========= PRIVATE FUNCTIONS =========
fn tokenize(lexer: Lexer, tokens: List(token.Token)) -> List(token.Token) {
  let #(token, rest) = case lexer.mode {
    Normal -> tokenize_normal_mode(lexer)
  }

  case token.kind {
    token.EOF -> [token, ..tokens]
    _continue -> {
      let lexer =
        Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

      tokenize(lexer, [token, ..tokens])
    }
  }
}

fn tokenize_normal_mode(lexer: Lexer) -> #(token.Token, BitArray) {
  case lexer.remaining_bytes {
    <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>> -> tokenize_number.tokenize(rest, lexer.position, 1)

    // TODO: this will eventually be exhaustive
    _ -> #(
      token.Token(kind: token.EOF, span: token.Span(start: 0, end: 0)),
      <<>>,
    )
  }
}
