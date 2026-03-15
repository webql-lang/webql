import gleam/bit_array
import gleam/list
import gleam/result
import webfn/lexer/lex_number
import webfn/lexer/lex_string
import webfn/lexer/span
import webfn/lexer/token
import webfn/lexer/tokenize_grouping

pub type LexerMode {
  Normal
}

pub type LexerError {
  IllegalToken(span: span.Span, message: String)
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
pub fn run(lexer: Lexer) -> Result(List(token.Token), LexerError) {
  let tokens = []

  case lex(lexer, tokens) {
    Ok(result) -> Ok(list.reverse(result))
    Error(message) -> Error(message)
  }
}

// ========= PRIVATE FUNCTIONS =========
fn lex(
  lexer: Lexer,
  tokens: List(token.Token),
) -> Result(List(token.Token), LexerError) {
  use #(token, rest) <- result.try(case lexer.mode {
    Normal -> lex_normal_mode(lexer)
  })

  case token.kind {
    token.EOF -> Ok([token, ..tokens])
    _continue -> {
      let lexer =
        Lexer(..lexer, remaining_bytes: rest, position: token.span.end)

      lex(lexer, [token, ..tokens])
    }
  }
}

fn lex_normal_mode(lexer: Lexer) -> Result(#(token.Token, BitArray), LexerError) {
  case lexer.remaining_bytes {
    // ======== NUMBER =========
    <<"0", rest:bytes>>
    | <<"1", rest:bytes>>
    | <<"2", rest:bytes>>
    | <<"3", rest:bytes>>
    | <<"4", rest:bytes>>
    | <<"5", rest:bytes>>
    | <<"6", rest:bytes>>
    | <<"7", rest:bytes>>
    | <<"8", rest:bytes>>
    | <<"9", rest:bytes>> -> Ok(lex_number.lex(rest, lexer.position, 1))

    // ========= STRING =========
    <<"\"", rest:bytes>> -> Ok(lex_string.lex(rest, lexer.position, 1))

    // ======= GROUPINGS ========
    <<"(", rest:bytes>>
    | <<")", rest:bytes>>
    | <<"[", rest:bytes>>
    | <<"]", rest:bytes>>
    | <<"{", rest:bytes>>
    | <<"}", rest:bytes>> -> {
      tokenize(lexer, rest, tokenize_grouping.tokenize)
    }

    // TODO: this will eventually be exhaustive
    _ ->
      Ok(
        #(token.Token(kind: token.EOF, span: span.Span(start: 0, end: 0)), <<>>),
      )
  }
}

fn tokenize(
  lexer: Lexer,
  bytes: BitArray,
  fun: fn(BitArray) -> Result(#(token.TokenKind, Int), String),
) {
  case fun(lexer.remaining_bytes) {
    Ok(#(kind, offset)) -> {
      let token = #(
        token.Token(
          kind:,
          span: span.Span(start: lexer.position, end: lexer.position + offset),
        ),
        bytes,
      )

      Ok(token)
    }

    Error(message) -> {
      let illegal =
        IllegalToken(
          span: span.Span(start: lexer.position, end: lexer.position),
          message: message,
        )

      Error(illegal)
    }
  }
}
