import std.stdio;
import std.file;

import lexer;
void main()
{
	Lexer lexer = Lexer();
	lexer.lex(readText("test.n"));
	writeln(lexer.tokens);
}
