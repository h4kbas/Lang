module parser;

import std.stdio;
import std.uni;
import std.file: readText;
import std.conv: to;
import std.algorithm: countUntil;
import std.math: abs;
import lexer;

class Parser{

  int mark = -1;
  Lexer lexer;
  Model[string] models;

  this(string file){
    models = [
      "int": new Model("int"),
      "string": new Model("string"),
      "bool": new Model("bool")
    ];
    lexer = Lexer();
    lexer.lex(readText(file));
  }

  void parse(){
    while(this.next.type != Type.EOF){
      Definition();
    }
  }

  @property Token current(){
    return lexer.tokens[mark];
  }

  @property Token next(){
    if(mark + 1 < lexer.tokens.length)
      return lexer.tokens[++mark];
    else
      return new Token(Type.EOF);
  }

  Token lookNext(ulong step = 1){
    if(mark + step < lexer.tokens.length)
      return lexer.tokens[mark + step];
    else
      return new Token(Type.EOF);
  }

  Token lookPrev(ulong step = 1){
    if(mark - step > 0)
      return lexer.tokens[mark - step];
    else
      return new Token(Type.SOF);
  }

  bool nextIf(Token t){
    return t == this.next;
  }

  bool nextIf(Type t){
    return t == this.next.type;
  }

  bool nextIf(string t){
    return t == this.next.text;
  }

  bool currentIf(Token t){
    return t == this.current;
  }

  bool currentIf(string t){
    return t == this.current.text;
  }

  void Definition(){
    if(this.current == "log")
      Log();
    else{
      if(this.current.toString() in models)
        throw new Error("This models has already been declared: "~this.current.toString());
      Model m = new Model();
      m.name = this.current;
      //Inheritance
      if(this.next == ":"){
        if(this.next.toString() in models){
          m.parent = models[this.current.toString()];
          this.next();
        }
        else
          throw new Error("Error parent is not defined yet");
      }
      //Elements
      if(this.current == "{"){
        while(this.next != "}"){
          ModelElement e = ModelElement();
          if(this.current.toString() !in models) 
            throw new Error("Error type is not defined: " ~ this.current.toString());
          e.type = models[this.current.toString()];
          e.name = this.next;
          m.elements ~= e;
          m.parent = null;
          if(this.current == Type.EOF)
            throw new Error("Error right brace expected");
        }
        models[m.name.toString()] = m;
      }
      else
        throw new Error("Error left brace expected");
    }
  }

  void Log(){
      writeln(this.next);
  }
}

class Model {
  Token name;
  ModelElement[] elements;
  Model parent;

  this(string n = null, Model p = null){
    this.name = new Token(n.to!(char[]), Type.Ident);
    this.parent = p;
  }
  override string toString(){
    return this.name.toString();
  }
}

struct ModelElement{
  Token name;
  Model type;
}