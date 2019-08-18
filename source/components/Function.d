module components.Function;



import util.keywords;
import util.errors;

import structures.func;

import parser;

import components.Scope;

void Function(Parser parser) {
  Func f = new Func(parser.storage.getModel(parser.current()), parser.next(), parser.scopedepth);
  f.params = Params(parser);
  parser.storage.functions[f.name.toString()] = f;
  f.block = Scope(parser, f.scopedepth);
}

Param[] Params(Parser parser) {
  Param[] params;
  bool first = true;
  if (!parser.nextIf(Keywords.L_Paren))
    throw new Exception(Errors.LeftParenExcpected);
  while (!parser.nextIf(Keywords.R_Paren)) {
    if (!first && !parser.currentIf(Keywords.Comma))
      throw new Exception(Errors.EitherCommaOrRParen);
    else if (parser.current == Keywords.Comma)
      parser.next();
    Param p = new Param(parser.storage.getModel(parser.current()), parser.next());
    params ~= p;
    if (first)
      first = false;
  }
  return params;
}

