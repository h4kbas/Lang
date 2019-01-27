import std.stdio;
import std.algorithm.iteration;
import parser;
import std.conv:to;
void main()
{
	Parser p = new Parser("test.n");
  p.parse();
  foreach(k,v; p.models){
    writeln(v.name, " ", v.parent);
    writeln(v.elements);
  }
}
