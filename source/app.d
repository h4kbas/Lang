import std.stdio;

import parser;
void main()
{
	Parser p = Parser("test.n");
  p.parse();
  //writeln(p.sets);
}
