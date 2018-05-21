module lexer;

import std.stdio;
import std.uni;

enum Type { None = -1, EOF = 0, SOF = 0, Ident, Str, Int, Sym};

struct Token {
  char [] text;
  Type type;
  this(Type t){
    this.type = t;  
  }
  this(char[] str, Type t){
    this.text = str;
    this.type = t;  
  }
  bool opEquals()(auto ref Token other) {
    return (this.text == other.text && this.type == other.type);
  }
}

struct Lexer {
  char [] x;
  uint mark = 0;
  Token[] tokens;

  void lex(string x){
    this.x ~= x;
    while(mark < x.length){
      if(isNumber(x[mark]))
        tokens ~= Int();
      else if(x[mark] == '"')
        tokens ~= Str();
      else if(isAlpha(x[mark]))
       tokens ~= Ident();
      else if( isPunctuation(x[mark]))
        tokens ~= Sym();
      else
        mark++;
    }
  }

  Token Int(){
    Token t;
    t.type = Type.Int;
    while(mark < x.length && isNumber(x[mark])){
      t.text ~= x[mark];
      mark++;
    }
    return t;
  }

   Token Str(){
    Token t;
    t.type = Type.Str;
    mark++;
    while(mark < x.length && x[mark] != '"'){
      t.text ~= x[mark];
      mark++;
    }
    mark++;
    return t;
  }

  Token Ident(){
    Token t;
    t.type = Type.Ident;
    while(mark < x.length && isAlphaNum(x[mark])){
      t.text ~= x[mark];
      mark++;
    }
    return t;
  }

  Token Sym(){
    Token t;
    t.type = Type.Sym;
    while(mark < x.length && isPunctuation(x[mark])){
      t.text ~= x[mark];
      mark++;
    }
    return t;
  }
}