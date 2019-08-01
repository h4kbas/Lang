module components.Statement;

import util.component;
import util.keywords;

class Statement: Component {
   
   override void parse() {
    if (parser.currentIf(Keywords.If))
      component("If").parse();
    else if (parser.currentIf(Keywords.Log))
      component("Log").parse();
    else if (parser.currentIf(Keywords.SComment))
      component("Comment").parse();
    else if (parser.currentIf(Keywords.L_MComment))
      component("MComment").parse();
    else
      component("Exp").parse();
  }

}