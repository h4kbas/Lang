module components.If;


import util.errors;
import util.keywords;

import parser;

import components.Scope;

  void If(Parser parser) {
    if (!parser.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);

    while (!parser.nextIf(Keywords.R_Paren)) {
    }
    Scope(parser, parser.scopedepth);
  }