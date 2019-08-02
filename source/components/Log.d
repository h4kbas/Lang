module components.Log;

import std.stdio: writeln;


import parser: Parser;
import util.type;

import parser;

void Log(Parser parser) {
    if (parser.nextIf(Type.Str))
      writeln(parser.current);
    else if (parser.getModel(parser.current, false)) {
      writeln(parser.getModel(parser.current).serialize());
    }
    else if (parser.getFunc(parser.current, false)) {
      writeln(parser.getFunc(parser.current).serialize());
    }
}
