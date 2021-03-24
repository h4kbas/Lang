module util.bytecode;

enum ByteCode {
  Push = 1,
  Load,
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