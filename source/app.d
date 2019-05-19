import std.stdio;
import std.algorithm.iteration;
import parser;
import std.conv : to;

void main() {
  Parser p = new Parser("test.n");
  //writeln(p.lexer.tokens);
  p.parse();
  /*
  foreach(k,v; p.models){
    writeln(v.name, " ", v.parent);
    writeln(v.elements);
  }
  */
}
