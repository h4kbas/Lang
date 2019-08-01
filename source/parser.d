module parser;

import std.stdio;
import std.uni;
import std.file : readText;
import std.conv : to;
import std.algorithm : countUntil;
import std.algorithm.iteration : each;
import std.algorithm.sorting : sort;
import std.math : abs;
import std.array : join, split;
import std.string : fromStringz;

import lexer;
import assembly;
import storage;

import util.errors;
import util.component;
import util.token;
import util.type;
import util.keywords;

import structures.model;
import structures.func;

class Parser {
  int mark = -1;

  Lexer lexer;
  Assembly assembly;
  Storage storage;
  Component[string] components;
  uint scopedepth = 0;


  this(string file) {
    storage = new Storage();

    Model _string = new Model("string");
    Model _int = new Model("int");

    _string.elements["length"] = ModelElement(new Token("length".dup), _int);
    storage.models = ["int": _int, "bool": new Model("bool"), "string": _string];

    lexer = Lexer();
    assembly = new Assembly();
    lexer.lex(readText(file));
  }

  void register(string name, Component component){
    if(name !in this.components){
      component.parser = this;
      this.components[name] = component;
    }
  }

  Component component(string name){
    if(name !in this.components)
      throw new Exception("Parser Error: "~name~" is not registered");
    return this.components[name];
  }

  void parse() {
    while (this.next.type != Type.EOF) {
      if (this.scopedepth > 0)
        component("Statement").parse();
      else
        component("GStatement").parse();
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
    if (s.toString() in storage.models) {
      return storage.models[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.ModelNotDefined ~ s.toString());
    else
      return null;
  }

  Func getFunc(Token s, bool bypass = true) {
    if (s.toString() in storage.functions) {
      return storage.functions[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.FuncNotDefined ~ s.toString());
    else
      return null;
  }

  ModelElement[string] ModelElements(bool modify = false) {
    ModelElement[string] melements;
    if (this.currentIf(Keywords.L_Brace)) {
      while (!this.nextIf(Keywords.R_Brace)) {
        ModelElement e = ModelElement();
        if (this.current.toString() !in storage.models) {
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

}


import components.Definition;
import components.If;
import components.Scope;
import components.Log;
import components.GStatement;
import components.Comment;
import components.MComment;
import components.Function;
import components.Statement;
import components.Exp;


Parser newParser(string filename){
  Parser p = new Parser(filename);
  p.register("Definition", new Definition());
  p.register("If", new If());
  p.register("Scope", new Scope());
  p.register("Log", new Log());
  p.register("GStatement", new GStatement());
  p.register("Comment", new Comment());
  p.register("MComment", new MComment());
  p.register("Function", new Function());
  p.register("Statement", new Statement());
  p.register("Exp", new Exp());
  return p;
}
