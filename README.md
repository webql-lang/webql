# WebQL

[![Package Version](https://img.shields.io/hexpm/v/webql)](https://hex.pm/packages/webql)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/webql/)

A dataflow language designed for building queries and representing directed graphs.

**WebQL is currently extremely experimental, and is subject to much change. Stay tuned!**

```webql
-> out: Int {
  m = Math
  1 -> m.lhs
  1 -> m.rhs
  m.value -> .out
}
```

WebQL was built in Gleam but targets Elixir and (hopefully) will target JS soon.
