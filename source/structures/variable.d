module structures.variable;

import structures.model;

import util.token;

class Variable{
  Token name;
  Model type;

  uint blockid;
  uint varid;
  uint length;
  
  //Interpreter
  double value;

  this(Model type, Token name){
    this.name = name;
    this.type = type;
  }
}