module components.If;

import util.component;
import util.errors;
import util.keywords;

class If : Component{

  override void parse() {
    if (!parser.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);

    while (!parser.nextIf(Keywords.R_Paren)) {
    }
    component("Scope").parse(parser.scopedepth);
  }

}
