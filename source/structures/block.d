module structures.block;

import structures.variable;

import util.token;
import util.bytecode;

class Block{
  uint id;
  uint varcount;
  Line[] Code;
  uint depth;
  Block parent;
  
  Variable[string] variables;
  
  this(uint blockid){
    this.id = blockid;
  }

  void InsertCode(ByteCode code, Token[] ts = []) {
    //writeln(code, ts); 
    this.Code ~= Line(code, ts);
  }

  void addVariable(Variable v){
    v.blockid = this.id;
    v.varid = ++this.varcount;
    this.variables[v.name.toString()] = v;
  }

  Variable getVariable(Token v){
    Block p = this;

    do{
      if(v.toString() in p.variables)
        return p.variables[v.toString()];
      else
        p = p.parent;
    }
    while(p);
    throw new Exception(v.toString()~" variable is not defined");
  }
}

struct Line{
  ByteCode operator;
  Token[] operands;
  
  this(ByteCode operator, Token[] operands){
    this.operator = operator;
    this.operands = operands;
  }
}
