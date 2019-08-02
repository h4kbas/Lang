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

import util.token;
import util.type;
import util.keywords;

import structures.model;
import structures.func;

import components.Statement;
import components.GStatement;

class Parser {
  int mark = -1;

  Lexer lexer;
  Assembly assembly;
  Storage storage;
  uint scopedepth = 0;


  this(string file, Assembly assembly) {
    storage = new Storage();

    Model _string = new Model("string");
    Model _int = new Model("int");

    _string.elements["length"] = ModelElement(new Token("length".dup), _int);
    storage.models = ["int": _int, "bool": new Model("bool"), "string": _string];

    lexer = Lexer();
    this.assembly = assembly;
    lexer.lex(readText(file));
  }

  void parse() {
    while (this.next.type != Type.EOF) {
      if (this.scopedepth > 0)
        Statement(this);
      else
        GStatement(this);
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


}
