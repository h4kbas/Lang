module components.While;


import util.errors;
import util.keywords;

import parser;

import components.Scope;

void While(Parser parser) {
  if (!parser.nextIf(Keywords.L_Paren))
    throw new Exception(Errors.LeftParenExcpected);

  while (!parser.nextIf(Keywords.R_Paren)) {
  }
  Scope(parser, parser.scopedepth);
}