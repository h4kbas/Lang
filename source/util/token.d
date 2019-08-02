module util.token;

import util.type;

import std.conv: to;

class Token
{
  char[] text;
  Type type;
  this(Type t)
  {
    this.type = t;
  }

  this(char[] str = [], Type t = Type.None)
  {
    this.text = str;
    this.type = t;
  }

  constbool opEquals()(auto ref Token other)
  {
    return (this.text == other.text && this.type == other.type);
  }

  bool opEquals()(auto ref string other)
  {
    return this.text == other;
  }

  bool opEquals()(auto ref Type other)
  {
    return this.type == other;
  }

  override string toString()
  {
    return this.text.to!string;
  }
}