module assembly;

import std.stdio;
import util.token;

import structures.variable;

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
  uint varcount;
  Line[] Code;
  
  Variable[string] variables;
  
  this(uint blockid){
    this.id = blockid;
  }

  void InsertCode(ByteCode code, Token[] ts = []) {
    writeln(code, ts);
    Line l = [code : ts];
    this.Code ~= l;
  }

  void addVariable(Variable v){
    v.blockid = this.id;
    v.varid = ++this.varcount;
    this.variables[v.name.toString()] = v;
  }
}

class Assembly {
  Block[] blocks;
  alias Line = Token[][ByteCode];
  Block currentBlock;
  uint blockid = 1;

  this(){
    this.NewBlock();
  }
  
  void NewBlock() {
    currentBlock = new Block(blockid++);
    blocks~=currentBlock;
  }

  void Push(Token t) {
    currentBlock.InsertCode(ByteCode.Push, [t]);
  }

  void Mul() {
    currentBlock.InsertCode(ByteCode.Mul);
  }

  void Div() {
    currentBlock.InsertCode(ByteCode.Div);
  }

  void Add() {
    currentBlock.InsertCode(ByteCode.Add);
  }

  void Sub() {
    currentBlock.InsertCode(ByteCode.Sub);
  }
}
