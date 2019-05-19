module parser;

import std.stdio;
import std.uni;
import std.file : readText;
import std.conv : to;
import std.algorithm : countUntil;
import std.algorithm.iteration : each;
import std.algorithm.sorting : sort;
import std.range.primitives : popBack;
import std.algorithm.mutation : reverse;
import std.math : abs;
import std.array : join;
import errors;
import lexer;
import assembly;

import model;
import func;

class Parser {
  int mark = -1;

  Lexer lexer;
  Assembly assembly;
  Model[string] models;
  Func[string] functions;
  uint scopedepth = 0;

  this(string file) {
    models = [
      "int": new Model("int"),
      "string": new Model("string"),
      "bool": new Model("bool")
    ];
    lexer = Lexer();
    assembly = new Assembly();
    lexer.lex(readText(file));
  }

  void parse() {
    while (this.next.type != Type.EOF) {
      if (this.scopedepth > 0)
        Statement();
      else
        GStatement();
    }
  }

  @property Token current() {
    return lexer.tokens[mark];
  }

  @property Token next(bool eol = false) {
    if (mark + 1 < lexer.tokens.length) {
      Token t = lexer.tokens[++mark];
      if (eol)
        return t;
      else {
        if (t.type == Type.EOL)
          return this.next;
        else {
          return t;
        }
      }
    }
    else
      return new Token(Type.EOF);
  }

  Token lookNext(ulong step = 1) {
    if (mark + step < lexer.tokens.length)
      return lexer.tokens[mark + step];
    else
      return new Token(Type.EOF);
  }

  Token lookPrev(ulong step = 1) {
    if (mark - step > 0)
      return lexer.tokens[mark - step];
    else
      return new Token(Type.SOF);
  }

  bool nextIf(Token t) {
    return t == this.next;
  }

  bool nextIf(Type t) {
    return t == this.next.type;
  }

  bool nextIf(string t) {
    return t == this.next.text;
  }

  bool currentIf(Token t) {
    return t == this.current;
  }

  bool currentIf(Type t) {
    return t == this.current.type;
  }

  bool currentIf(string t) {
    return t == this.current.text;
  }

  Model getModel(Token s, bool bypass = true) {
    if (s.toString() in models) {
      return models[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.ModelNotDefined ~ s.toString());
    else
      return null;
  }

  Func getFunc(Token s, bool bypass = true) {
    if (s.toString() in functions) {
      return functions[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.FuncNotDefined ~ s.toString());
    else
      return null;
  }

  void Definition() {

    //Extend
    if (this.currentIf(Keywords.Modify)) {
      if (this.next.toString() !in models)
        throw new Error(Errors.CantModifyUndefinedModel);
      Model m = models[this.current.toString()];
      this.next();
      auto elements = ModelElements(true);
      foreach (name, e; elements) {
        if (e.type !is null) {
          if (name !in m.elements) {
            m.elements[name] = e;
          }
          else
            throw new Error(Errors.CantChangeAlreadyDefinedElement);
        }
        else {
          if (name in m.elements)
            m.elements.remove(name);
          else
            throw new Error(Errors.CantDeleteUndefinedElement);
        }
      }
    }
    else {
      if (this.current.toString() in models)
        throw new Error(Errors.ModelAlreadyDeclared ~ this.current.toString());
      if (this.currentIf(Keywords.Delete))
        throw new Error(Errors.DeleteReserved);
      Model m = new Model(this.current.toString());
      //Inheritance
      if (this.nextIf(Keywords.Colon)) {
        if (this.next.toString() in models) {
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

  void GStatement() {
    if (this.currentIf(Keywords.Log))
      Log();
    else if (this.currentIf(Keywords.SComment))
      Comment();
    else if (this.currentIf(Keywords.L_MComment))
      MComment();
    else if (this.current.toString() in models) {
      Function();
    }
    else
      Definition();
  }

  void Statement() {
    if (this.currentIf(Keywords.If))
      If();
    else if (this.currentIf(Keywords.Log))
      Log();
    else if (this.currentIf(Keywords.SComment))
      Comment();
    else if (this.currentIf(Keywords.L_MComment))
      MComment();
    else
      Exp();
  }

  ModelElement[string] ModelElements(bool modify = false) {
    ModelElement[string] melements;
    if (this.currentIf(Keywords.L_Brace)) {
      while (!this.nextIf(Keywords.R_Brace)) {
        ModelElement e = ModelElement();
        if (this.current.toString() !in models) {
          if (modify) {
            if (this.currentIf(Keywords.Delete))
              e.type = null;
          }
          else
            throw new Error(Errors.TypeNotDefined ~ this.current.toString());
        }
        else {
          e.type = this.getModel(this.current);
        }
        e.name = this.next;
        melements[e.name.toString()] = e;
        if (this.currentIf(Type.EOF))
          throw new Error(Errors.RightBraceExpected);
      }
      return melements;
    }
    else
      throw new Error(Errors.LeftBraceExpected);
  }

  void Log() {
    if (this.nextIf(Type.Str))
      writeln(this.current);
    else if (this.getModel(this.current, false)) {
      writeln(this.getModel(this.current).serialize());
    }
    else if (this.getFunc(this.current, false)) {
      writeln(this.getFunc(this.current).serialize());
    }
  }

  void Comment() {
    while (!this.currentIf(Type.EOL)) {
      this.next(true);
    }
  }

  void MComment() {
    while (!this.currentIf(Keywords.R_MComment)) {
      this.next();
    }
  }

  void Function() {
    Func f = new Func(this.getModel(this.current()), this.next(), this.scopedepth);
    f.params = Params();
    functions[f.name.toString()] = f;
    Scope(f.scopedepth);
  }

  void If() {
    if (!this.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);

    while (!this.nextIf(Keywords.R_Paren)) {
    }
    Scope(this.scopedepth);
  }

  void Scope(uint depth) {
    if (!this.nextIf(Keywords.L_Brace))
      throw new Exception(Errors.LeftBraceExpected);
    this.scopedepth++;
    while (!this.nextIf(Keywords.R_Brace) && this.scopedepth != depth) {
      Statement();
    }
    if (!this.currentIf(Keywords.R_Brace))
      throw new Exception(Errors.RightBraceExpected);
    this.scopedepth--;
  }

  Param[] Params() {
    Param[] params;
    bool first = true;
    if (!this.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);
    while (!this.nextIf(Keywords.R_Paren)) {
      if (!first && !this.currentIf(Keywords.Comma))
        throw new Exception(Errors.EitherCommaOrRParen);
      else if (this.current == Keywords.Comma)
        this.next();
      Param p = new Param(this.getModel(this.current()), this.next());
      params ~= p;
      if (first)
        first = false;
    }
    return params;
  }

  Token[] Operands;
  Token[] Operators;

  void Exp() {
    if (isOperator(this.current)) {
      while (Operators.length && precedence(this.current) <= precedence(Operators[$ - 1])) {
        Operands ~= Operators[$ - 1];
        Operators.popBack();
      }
      Operators ~= this.current;
    }
    else if (this.currentIf(Keywords.L_Paren)) {
      Operators ~= this.current;
    }
    else if (this.currentIf(Keywords.R_Paren)) {
      while (Operators[$ - 1].text != Keywords.L_Paren) {
        Operands ~= Operators[$ - 1];
        Operators.popBack();
      }
      Operators.popBack();
    }
    else if (this.currentIf(Keywords.SemiColon)) {
      Operands = (Operands ~ Operators.reverse()).reverse();
      Operators = [];
      CalcIt();
    }
    else if (!isOperator(this.current)) {
      this.Operands ~= this.current;
    }
  }

  bool isOperator(Token x) {
    return [
      Keywords.Times, Keywords.Plus, Keywords.PPlus, Keywords.Minus,
      Keywords.MMinus, Keywords.Assign, Keywords.Divide, Keywords.And,
      Keywords.Or, Keywords.Xor, Keywords.Not
    ].canFind(x.text);
  }

  uint precedence(Token t) {
    if ([Keywords.PPlus, Keywords.MMinus].canFind(t.text))
      return 8;
    if ([Keywords.Not].canFind(t.text))
      return 7;
    if ([Keywords.Times, Keywords.Divide].canFind(t.text))
      return 6;
    else if ([Keywords.Plus, Keywords.Minus].canFind(t.text))
      return 5;
    else if ([Keywords.And].canFind(t.text))
      return 4;
    else if ([Keywords.Xor].canFind(t.text))
      return 3;
    else if ([Keywords.Or].canFind(t.text))
      return 2;
    else if ([Keywords.Assign].canFind(t.text))
      return 1;
    else
      return 0;
  }

  void CalcIt() {
    bool first = true;
    while (Operands.length > 0) {
      if (!isOperator(Operands[$ - 1])) {
        Operators ~= Operands[$ - 1];
        Operands.popBack();
      }
      else {
        if (first) {
          assembly.Push(Operators[$ - 1]);
          Operators.popBack();
        }
        assembly.Push(Operators[$ - 1]);
        Operators.popBack();

        final switch (Operands[$ - 1].text) {
        case Keywords.Plus:
          assembly.Add();
          break;
        case Keywords.Minus:
          assembly.Sub();
          break;

        case Keywords.Times:
          assembly.Mul();
          break;
        case Keywords.Divide:
          assembly.Div();
          break;
        }
        Operands.popBack();
        first = false;
      }
    }
  }

}
