module components.Comment;

import util.component;

import util.type;

class Comment: Component {
   
   override void parse() {
    while (!parser.currentIf(Type.EOL)) {
      parser.next(true);
    }
  }

}