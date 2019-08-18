module lexer;

import std.stdio;
import std.uni;
import std.conv : to;
import std.algorithm : canFind;

import util.token;
import util.keywords;
import util.type;

struct Lexer
{
  char[] x;
  uint mark = 0;
  Token[] tokens;

  void lex(string x)
  {
    this.x ~= x;
    while (mark < x.length)
    {
      if (isNumber(x[mark]))
        tokens ~= Int();
      else if (x[mark] == '"')
        tokens ~= Str();
      else if (isAlpha(x[mark]))
        tokens ~= Ident();
      else if (isPunctuation(x[mark]))
        tokens ~= Sym();
      else if (x[mark] == '\n')
      {
        tokens ~= new Token(Type.EOL);
        mark++;
      }
      else
        mark++;
    }
  }

  Token Int()
  {
    Token t = new Token();
    t.type = Type.Int;
    while (mark < x.length && isNumber(x[mark]))
    {
      t.text ~= x[mark];
      mark++;
    }
    return t;
  }

  Token Str()
  {
    Token t = new Token();
    t.type = Type.Str;
    mark++;
    while (mark < x.length && x[mark] != '"')
    {
      t.text ~= x[mark];
      mark++;
    }
    mark++;
    return t;
  }

  Token Ident()
  {
    Token t = new Token();
    t.type = Type.Ident;
    while (mark < x.length && isAlphaNum(x[mark]))
    {
      t.text ~= x[mark];
      mark++;
    }
    return t;
  }

  Token Sym()
  {
    Token t = new Token();
    t.type = Type.Sym;
    while (mark < x.length && isPunctuation(x[mark]))
    {
      t.text ~= x[mark];
      mark++;
      if (!["+", "-", "/", "*", "|", "&", "="].canFind(t.text))
        break;
    }
    return t;
  }
}