pub type Resolution(a, b) {
  Pending(perform: fn(fn(Result(a, b)) -> Nil) -> Nil)
  Done(Result(a, b))
}
