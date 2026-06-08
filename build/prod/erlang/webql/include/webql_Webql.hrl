-record(webql, {
    memory :: webql@memory:memory(any()),
    engine :: webql@engine:engine(any(), webql@memory:memory(any()), webql@diagnostic:diagnostic())
}).
