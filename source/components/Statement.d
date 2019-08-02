module components.Statement;


import util.keywords;

import components.If;
import components.While;
import components.For;
import components.Log;
import components.Comment;
import components.MComment;
import components.Exp;
import components.Var;

import parser;

void Statement(Parser parser) {
  if (parser.currentIf(Keywords.If))
    If(parser);
  else if (parser.currentIf(Keywords.While))
    While(parser);
  else if (parser.currentIf(Keywords.For))
    For(parser);
  else if (parser.currentIf(Keywords.Log))
    Log(parser);
  else if (parser.currentIf(Keywords.SComment))
    Comment(parser);
  else if (parser.currentIf(Keywords.L_MComment))
    MComment(parser);
  else if (parser.storage.getModel(parser.current, false))
    Var(parser);
  else
    Exp(parser);
}