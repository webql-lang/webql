-record(lexer, {
    source :: binary(),
    bytes :: bitstring(),
    remaining_bytes :: bitstring(),
    position :: integer(),
    mode :: webql@compiler@lexer:lexer_mode(),
    comments :: boolean(),
    whitespace :: boolean()
}).
