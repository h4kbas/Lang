module components.MComment;

import util.component;
import util.keywords;
import util.type;

class MComment: Component {
   
   override void parse() {
    while (!parser.currentIf(Keywords.R_MComment)) {
      parser.next();
    }
  }

}