module parser;

import std.stdio;
import std.uni;
import std.file: readText;
import std.conv: to;
import std.algorithm: countUntil;
import std.math: abs;
import errors;
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
      if(this.current==Keywords.Log||this.current==Keywords.SComment||this.current==Keywords.L_MComment)
        GExpression();
      else
        Definition();
    }
  }

  @property Token current(){
    return lexer.tokens[mark];
  }

  @property Token next(bool eol = false){
    if(mark + 1 < lexer.tokens.length){
      Token t = lexer.tokens[++mark];
      if(eol) 
        return t;
      else{
        if(t.type == Type.EOL)
          return this.next;
        else
          return t;
      }
    }
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
    
    //Extend
    if(this.current == Keywords.Modify){
      if(this.next.toString() !in models)
        throw new Error(Errors.CantModifyUndefinedModel);
      Model m = models[this.current.toString()];
      this.next();
      auto elements = ModelElements(true);
      foreach(name, e; elements){
        if(e.type !is null){
          if(name !in m.elements){
            m.elements[name] = e;
          }
          else
            throw new Error(Errors.CantChangeAlreadyDefinedElement);
        }
        else{
          if(name in m.elements)
            m.elements.remove(name);
          else
            throw new Error(Errors.CantDeleteUndefinedElement);
        }
      }
    }
    else{
      if(this.current.toString() in models)
        throw new Error(Errors.ModelAlreadyDeclared~this.current.toString());
      if(this.current.toString() == "delete")
          throw new Error(Errors.DeleteReserved);
      Model m = new Model(this.current.toString());
      //Inheritance
      if(this.next == Keywords.Colon){
        if(this.next.toString() in models){
          m.parent = models[this.current.toString()];
          this.next();
        }
        else
          throw new Error(Errors.ParentModelNotDefined);
      }
     m.elements = ModelElements();
     models[m.name.toString()] = m;
    }
  }

  void GExpression(){
    if(this.current == Keywords.Log)
      Log();
    else if(this.current == Keywords.SComment)
      Comment();
    else if(this.current == Keywords.L_MComment)
      MComment();
  }

  ModelElement[string] ModelElements(bool modify = false){
    ModelElement[string] melements;
      if(this.current == Keywords.L_Brace){
        while(this.next != Keywords.R_Brace){
          ModelElement e = ModelElement();
          if(this.current.toString() !in models) {
            if(modify){
              if(this.current.toString() == Keywords.Delete)
                e.type = null;
            }
            else
              throw new Error(Errors.TypeNotDefined~this.current.toString());
          }
          else{
              e.type = models[this.current.toString()];
          }
          e.name = this.next;
          melements[e.name.toString()] = e;
          if(this.current == Type.EOF)
            throw new Error(Errors.RightBraceExpected);
        }
        return melements;
      }
      else
        throw new Error(Errors.LeftBraceExpected);
  }

  void Log(){
      if(this.next == Type.Str)
        writeln(this.current);
      else{
        if(this.current.toString() in models){
          writeln(models[this.current.toString()].serialize());
        }
      }
  }

  void Comment(){
    while(this.current != Type.EOL){
      this.next(true);
    }
  }
  void MComment(){
    while(this.current != Keywords.R_MComment){
      this.next();
    }
  }
}

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
    char[] c = ""~this.name.toString().to!(char[]);
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