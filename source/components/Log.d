module components.Log;

import std.stdio: writeln;


import parser: Parser;
import util.type;

import parser;

void Log(Parser parser) {
    if (parser.nextIf(Type.Str))
      writeln(parser.current);
    else if (parser.storage.getModel(parser.current, false)) {
      writeln(parser.storage.getModel(parser.current).serialize());
    }
    else if (parser.storage.getFunc(parser.current, false)) {
      writeln(parser.storage.getFunc(parser.current).serialize());
    }
}
