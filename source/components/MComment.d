module components.MComment;


import util.keywords;
import util.type;

import parser;

void MComment(Parser parser) {
  while (!parser.currentIf(Keywords.R_MComment)) {
    parser.next();
  }
}