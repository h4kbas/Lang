module components.Scope;

import util.component;
import util.errors;
import util.keywords;

class Scope: Component{

  override void parse(uint depth) {
    if (!parser.nextIf(Keywords.L_Brace))
      throw new Exception(Errors.LeftBraceExpected);
    parser.scopedepth++;
    while (!parser.nextIf(Keywords.R_Brace) && parser.scopedepth != depth) {
      component("Statement").parse();
    }
    if (!parser.currentIf(Keywords.R_Brace))
      throw new Exception(Errors.RightBraceExpected);
    parser.scopedepth--;
  }

}