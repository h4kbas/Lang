module util.token;

import util.type;

import std.conv: to;

import std.string: isNumeric;
import std.math: isNaN;

class Token
{
  char[] text;
  double value;
  Type type;
  this(Type t)
  {
    this.type = t;
  }

  this(char[] t)
  {
    this.text = t;
    this.prepValue();
  }
  this(double v)
  {
    this.value = v;
  }
  this(bool v)
  {
    this.value = v ? 1 : 0;
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

  void prepValue(){
    if(isNaN(this.value))
      this.value = isNumeric(this.text) ? this.text.to!double : 0;
  }
}