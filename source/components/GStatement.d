module components.GStatement;

import util.component;
import util.keywords;

class GStatement: Component {
   
    override void parse() {
    if (parser.currentIf(Keywords.Log))
      component("Log").parse();
    else if (parser.currentIf(Keywords.SComment))
      component("Comment").parse();
    else if (parser.currentIf(Keywords.L_MComment))
      component("MComment").parse();
    else if (parser.current.toString() in parser.storage.models) {
      component("Function").parse();
    }
    else
      component("Definition").parse();
  }

}