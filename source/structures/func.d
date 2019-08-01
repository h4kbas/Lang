module structures.func;

import util.type;
import util.token;

import structures.model: Model;
import std.conv: to;

class Func{
  Token name;
  uint scopedepth;
  Func parent;
  Model type;
  Param[] params;
  this(Model type, Token name, uint sd){
    this.type = type;
    this.name = name;
    this.scopedepth = sd;
    this.parent = null;
  }

  override string toString(){
    return this.name.toString();
  }
  string serialize(){
    char[] c = this.name.toString().to!(char[]);
    if(this.parent){
      c ~= ": "~this.parent.toString();
    }
    c~=" ( PCount"~params.length.to!string;
    foreach(e; params){
      c ~= e.type.toString()~" "~e.name.toString()~" ";
    }
    c~=" )";
    return c.to!string;
  }
}

class Param{
  Token name;
  Model type;

  this(Model type, Token name){
    this.type = type;
    this.name = name;
  }
}