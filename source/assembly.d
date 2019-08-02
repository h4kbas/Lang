module assembly;

import std.stdio;
import util.token;

enum ByteCode {
  Push,

  Div,
  Mul,

  Add,
  Sub,

}

alias Line = Token[][ByteCode];

class Block{
  uint id;
  Line[] Code;

  this(uint blockid){
    this.id = blockid;
  }
}

class Assembly {
  Block[] blocks;
  alias Line = Token[][ByteCode];
  Block currentBlock;
  uint blockid = 1;

  this(){
    this.NewBlock(blockid);
  }
  
  void NewBlock(uint blockid) {
    currentBlock = new Block(blockid++);
    blocks~=currentBlock;
  }

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
    writeln(code, ts);
    Line l = [code : ts];
    currentBlock.Code ~= l;
  }
}
