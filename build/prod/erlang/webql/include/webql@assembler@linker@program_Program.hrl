-record(program, {
    nodes :: gleam@dict:dict(binary(), webql@assembler@linker@program:node_(any())),
    edges :: list(webql@assembler@linker@program:edge())
}).
