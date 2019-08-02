module components.Scope;


import util.errors;
import util.keywords;

import components.Statement;

import parser;

void Scope(Parser parser, uint depth) {
  if (!parser.nextIf(Keywords.L_Brace))
    throw new Exception(Errors.LeftBraceExpected);
  parser.scopedepth++;
  while (!parser.nextIf(Keywords.R_Brace) && parser.scopedepth != depth) {
    Statement(parser);
  }
  if (!parser.currentIf(Keywords.R_Brace))
    throw new Exception(Errors.RightBraceExpected);
  parser.scopedepth--;
}

