module components.Comment;


import util.type;

import parser;

void Comment(Parser parser) {
    while (!parser.currentIf(Type.EOL)) {
      parser.next(true);
    }
}