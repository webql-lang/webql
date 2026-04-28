pub type Preschema {
  Preschema(
    typenames: List(String),
    nodes: List(#(String, List(#(String, String)), List(#(String, String)))),
  )
}
