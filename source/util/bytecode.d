module util.bytecode;

enum ByteCode {
  Push = 1,
  Assign,

  Inc,
  Dec,

  Div,
  Mul,

  Add,
  Sub,

  Not,
  And,
  Or,
  Xor,

  Br
}