module parser;

import std.stdio;
import std.uni;
import std.file: readText;
import std.conv: to;
import std.algorithm: countUntil;
import std.math: abs;
import errors;
import lexer;
import model;


class Parser{
  int mark = -1;
  Lexer lexer;
  Model[string] models;
  Func[string] functions;
  uint scopedepth = 0;

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
      if(this.scopedepth > 0)
        Statement();
      else
        GStatement();
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
        else{
          return t;
        }
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

  bool currentIf(Type t){
    return t == this.current.type;
  }

  bool currentIf(string t){
    return t == this.current.text;
  }

  Model getModel(Token s, bool bypass = true){
    if(s.toString() in models){
      return models[s.toString()];
    }
    if(bypass)
      throw new Exception(Errors.ModelNotDefined~s.toString());
    else
      return null;
  }

  Func getFunc(Token s, bool bypass = true){
    if(s.toString() in functions){
      return functions[s.toString()];
    }
    if(bypass)
      throw new Exception(Errors.FuncNotDefined~s.toString());
    else
      return null;
  }

  void Definition(){
    
    //Extend
    if(this.currentIf(Keywords.Modify)){
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
      if(this.currentIf(Keywords.Delete))
          throw new Error(Errors.DeleteReserved);
      Model m = new Model(this.current.toString());
      //Inheritance
      if(this.nextIf(Keywords.Colon)){
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

  void GStatement(){
    if(this.currentIf(Keywords.Log))
      Log();
    else if(this.currentIf(Keywords.SComment))
      Comment();
    else if(this.currentIf(Keywords.L_MComment))
      MComment();
    else if(this.current.toString() in models){
      Function();
    }
    else
      Definition();
  }

  void Statement(){
    this.current.writeln;
    if(this.currentIf(Keywords.If))
      If();
    else if(this.currentIf(Keywords.Log))
      Log();
    else if(this.currentIf(Keywords.SComment))
      Comment();
    else if(this.currentIf(Keywords.L_MComment))
      MComment();
  }

  ModelElement[string] ModelElements(bool modify = false){
    ModelElement[string] melements;
      if(this.currentIf(Keywords.L_Brace)){
        while(!this.nextIf(Keywords.R_Brace)){
          ModelElement e = ModelElement();
          if(this.current.toString() !in models) {
            if(modify){
              if(this.currentIf(Keywords.Delete))
                e.type = null;
            }
            else
              throw new Error(Errors.TypeNotDefined~this.current.toString());
          }
          else{
              e.type = this.getModel(this.current);
          }
          e.name = this.next;
          melements[e.name.toString()] = e;
          if(this.currentIf(Type.EOF))
            throw new Error(Errors.RightBraceExpected);
        }
        return melements;
      }
      else
        throw new Error(Errors.LeftBraceExpected);
  }

  void Log(){
      if(this.nextIf(Type.Str))
        writeln(this.current);
      else if(this.getModel(this.current, false)){
        writeln(this.getModel(this.current).serialize());
      }
      else if(this.getFunc(this.current, false)){
        writeln(this.getFunc(this.current).serialize());
      }
  }

  void Comment(){
    while(!this.currentIf(Type.EOL)){
      this.next(true);
    }
  }

  void MComment(){
    while(!this.currentIf(Keywords.R_MComment)){
      this.next();
    }
  }

  void Function(){
    Func f = new Func(this.getModel(this.current()), this.next(), this.scopedepth);
    if(!this.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);
    while(!this.nextIf(Keywords.R_Paren)){
      Param p = new Param(this.getModel(this.current()), this.next());
      f.params ~= p;
    }
    functions[f.name.toString()] = f;
    Scope(f.scopedepth);
  }

  void If(){
    if(!this.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);

    while(!this.nextIf(Keywords.R_Paren)){
    }
    Scope(this.scopedepth);
  }

  void Scope(uint depth){
    if(!this.nextIf(Keywords.L_Brace)) 
      throw new Exception(Errors.LeftBraceExpected);
    this.scopedepth++;    
    while(!this.nextIf(Keywords.R_Brace) && this.scopedepth != depth){
      Statement();
    }
    if(!this.currentIf(Keywords.R_Brace)) 
      throw new Exception(Errors.RightBraceExpected);
    this.scopedepth--;
  }
  
}

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
    c~=" ( ";
    foreach(e; params){
      c ~= e.type.toString()~" "~e.name.toString();
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