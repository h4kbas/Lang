module components.GStatement;


import util.keywords;

import parser;
import components.Log;
import components.MComment;
import components.Function;
import components.Definition;
import components.Comment;



void GStatement(Parser parser) {
  if (parser.currentIf(Keywords.Log))
    Log(parser);
  else if (parser.currentIf(Keywords.SComment))
    Comment(parser);
  else if (parser.currentIf(Keywords.L_MComment))
    MComment(parser);
  else if (parser.current.toString() in parser.storage.models) {
    Function(parser);
  }
  else
    Definition(parser);
}