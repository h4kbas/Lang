module model;

import lexer: Token, Type;
import std.conv: to;
class Model {
  Token name;
  ModelElement[string] elements;
  Model parent;

  this(string n = null, Model p = null){
    this.name = new Token(n.to!(char[]), Type.Ident);
    this.parent = p;
  }
  override string toString(){
    return this.name.toString();
  }

  string serialize(){
    char[] c = this.name.toString().to!(char[]);
    if(this.parent){
      c ~= ": "~this.parent.toString();
    }
    c~="\n{\n";
    foreach(name, e; elements){
      c ~= "\t"~e.type.toString()~" "~e.name.toString()~"\n";
    }
    c~="}";
    return c.to!string;
  }
}

struct ModelElement{
  Token name;
  Model type;
}