module assembly;

import lexer;

enum ByteCode {
  Push,

  Div,
  Mul,

  Add,
  Sub,

}

class Assembly {

  alias Line = Token[][ByteCode];
  Line[] Code;
  void Push(Token t) {
    InsertCode(ByteCode.Push, [t]);
  }

  void Mul() {
    InsertCode(ByteCode.Mul);
  }

  void Div() {
    InsertCode(ByteCode.Div);
  }

  void Add() {
    InsertCode(ByteCode.Add);
  }

  void Sub() {
    InsertCode(ByteCode.Sub);
  }

  void InsertCode(ByteCode code, Token[] ts = []) {
    Line l = [code : ts];
    Code ~= l;
  }
}
