pub type Blueprint {
  Blueprint(
    typenames: List(String),
    nodes: List(#(String, List(#(String, String)), List(#(String, String)))),
  )
}
