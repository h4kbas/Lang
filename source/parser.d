module parser;

import std.stdio;
import std.uni;
import std.file: readText;
import std.conv: to;
import std.algorithm: countUntil;
import std.math: abs;
import lexer;

struct ParseSet{
  Token target;
  Token [] items;
  string[] params;
}

struct Parser{
  ParseSet[] [string] sets;
  int mark = -1;
  Lexer lexer;
  this(string file){
    lexer = Lexer();
    lexer.lex(readText(file));
  }

  void parse(){
    while(this.next().type != Type.EOF){
      //Define
      Token current = this.current();
      if(current.text == "define")
        Define();
      else if((current.text in this.sets) !is null)
        Custom();
    }
  }

  Token current(){
    return lexer.tokens[mark];
  }

  Token next(){
    if(mark + 1 < lexer.tokens.length)
      return lexer.tokens[++mark];
    else
      return Token(Type.EOF);
  }

  Token lookNext(ulong step = 1){
    if(mark + step < lexer.tokens.length)
      return lexer.tokens[mark + step];
    else
      return Token(Type.EOF);
  }

  Token lookPrev(ulong step = 1){
    if(mark - step > 0)
      return lexer.tokens[mark - step];
    else
      return Token(Type.SOF);
  }

  bool nextIf(Token t){
    return t == this.next();
  }

  bool nextIf(Type t){
    return t == this.next().type;
  }

  bool nextIf(string t){
    return t == this.next().text;
  }

  bool currentIf(Token t){
    return t == this.current();
  }

  bool currentIf(string t){
    return t == this.current().text;
  }

  
  ParseSet findParseSet(){
    const Token target = this.current();
    ParseSet[] poss_set = this.sets[this.current().text];
    ParseSet set;
    for(uint i = 0; i < poss_set.length; i++){
      bool suit = false;
      uint place_of_target;
      uint targetpos = to!uint(countUntil!"a.text == b.text"(poss_set[i].items, target));
      //Next
      for(int j = targetpos + 1; j < poss_set[i].items.length; j++){
        Token item = poss_set[i].items[j];
        if(item.text != ""){
          if(item.text != this.lookNext(j - targetpos).text){
            suit = false;
            break;
          }
          else
            suit = true;
        }
        else {
          if(item.type != this.lookNext(j - targetpos).type){
            suit = false;
            break;
          }
          else
            suit = true;
        }
      }
      //Prev
      for(int j = targetpos - 1; j > -1; j--){
        Token item = poss_set[i].items[j];
        if(item.text != ""){
          if(item.text != this.lookPrev(targetpos - j).text){
            suit = false;
            break;
          }
          else
            suit = true;
        }
        else {
          if(item.type != this.lookPrev(targetpos - j).type){
            suit = false;
            break;
          }
          else
            suit = true;
        }
      }
      if(suit){
        set = poss_set[i];
        break;
      }
    }
    return set;
  }

  void Define(){
    ParseSet set;
    set.target = this.next(); 
    set.target.type = Type.Ident;
    if(this.nextIf("as")){
      while(this.next().text != "{" && this.current().type != Type.EOF){
        if(this.current().text == "_"){
          set.params ~= "_";
          set.items ~= set.target;
        }
        else if(this.current().type == Type.Ident && this.lookNext().text == ":"){
          Token t;
          set.params ~= to!string(this.current().text);
          //:
          this.next();
          t.type = to!Type(this.next().text);
          set.items ~= t;
        }
        else{
          Token t;
          t.type = Type.Ident;
          t.text = this.current().text;
          set.items ~= t;
        }
      }
      this.sets[to!string(set.target.text)] ~= set;
    }
    else
      throw new Exception("\"as\" is expected after define <Str>");
  }

  void Custom(){
    ParseSet set = this.findParseSet();
    writeln("Found: ",set);
  }
}