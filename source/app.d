import std.stdio;
import parser;
import assembly;
import storage;

import interpreter;

import std.traits;
void main() {
  Assembly assembly = new Assembly();
  Storage storage = new Storage();
  Parser p = new Parser("samples/math.n", assembly, storage);
  p.parse();

	Interpreter t = new Interpreter();
	t.interpret(p.assembly, 1);
	
	import util.log: log;
	foreach(b; assembly.blocks){
			writeln(b.variables["a"].value);
	}
	
}

