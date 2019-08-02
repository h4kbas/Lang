module structures.variable;

import structures.model;

import util.token;

class Variable{
  Token name;
  Model type;

  uint blockid;
  uint varid;
  uint length;
  uint heap;
  uint value;

  this(Model type, Token name){
    this.name = name;
    this.type = type;
  }
}