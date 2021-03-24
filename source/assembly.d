module assembly;

import std.stdio;
import util.token;

import structures.block;

import util.bytecode;



class Assembly {
  Block[] blocks;
  Block currentBlock;
  uint blockid = 1;

  
  Block NewBlock(uint scopedepth) {
    currentBlock = new Block(blockid++);
    currentBlock.depth = scopedepth;
    blocks~=currentBlock;
    return currentBlock;
  }

  void Push(Token t) {
    currentBlock.InsertCode(ByteCode.Push, [t]);
  }

  // Math
  void PPlus(Token t) {
    currentBlock.InsertCode(ByteCode.Inc, [t]);
  }

  void MMinus(Token t) {
    currentBlock.InsertCode(ByteCode.Dec, [t]);
  }

  void Times() {
    currentBlock.InsertCode(ByteCode.Mul);
  }

  void Divide() {
    currentBlock.InsertCode(ByteCode.Div);
  }

  void Plus() {
    currentBlock.InsertCode(ByteCode.Add);
  }

  void Minus() {
    currentBlock.InsertCode(ByteCode.Sub);
  }

  // Bitwise

  void BAnd() {
    currentBlock.InsertCode(ByteCode.And);
  }

  void BOr() {
    currentBlock.InsertCode(ByteCode.Or);
  }

  void Not() {
    currentBlock.InsertCode(ByteCode.Not);
  }

  void Xor() {
    currentBlock.InsertCode(ByteCode.Xor);
  }

  //Logical
  void And() {
    currentBlock.InsertCode(ByteCode.And);
  }

  void Or() {
    currentBlock.InsertCode(ByteCode.Or);
  }

  // Assign
  void Assign(Token t) {
    currentBlock.InsertCode(ByteCode.Assign, [t]);
  }
  void AssignTimes(Token t) {
    currentBlock.InsertCode(ByteCode.Mul);
    currentBlock.InsertCode(ByteCode.Assign, [t]);
  }
  void AssignDivide(Token t) {
    currentBlock.InsertCode(ByteCode.Div);
    currentBlock.InsertCode(ByteCode.Assign, [t]);
  }
  void AssignPlus(Token t) {
    currentBlock.InsertCode(ByteCode.Add);
    currentBlock.InsertCode(ByteCode.Assign, [t]);
  }
  void AssignMinus(Token t) {
    currentBlock.InsertCode(ByteCode.Sub);
    currentBlock.InsertCode(ByteCode.Assign, [t]);
  }

  //Branch
  void Br(Token t){
    currentBlock.InsertCode(ByteCode.Br, [t]);
  }
}
