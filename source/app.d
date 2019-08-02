import std.stdio;
import parser;
import assembly;
import storage;
void main() {
  Assembly assembly = new Assembly();
  Storage storage = new Storage();
  Parser p = new Parser("test.n", assembly, storage);
  p.parse();
}

