import std.stdio;
import parser;
import assembly;
void main() {
  Assembly assembly = new Assembly();
  Parser p = new Parser("test.n", assembly);
  p.parse();
}

