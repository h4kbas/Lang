module components.Function;


import util.component;
import util.keywords;
import util.errors;

import structures.func;

class Function: Component {
   
   override void parse() {
    Func f = new Func(parser.getModel(parser.current()), parser.next(), parser.scopedepth);
    f.params = Params();
    parser.storage.functions[f.name.toString()] = f;
    component("Scope").parse(f.scopedepth);
  }

   Param[] Params() {
    Param[] params;
    bool first = true;
    if (!parser.nextIf(Keywords.L_Paren))
      throw new Exception(Errors.LeftParenExcpected);
    while (!parser.nextIf(Keywords.R_Paren)) {
      if (!first && !parser.currentIf(Keywords.Comma))
        throw new Exception(Errors.EitherCommaOrRParen);
      else if (parser.current == Keywords.Comma)
        parser.next();
      Param p = new Param(parser.getModel(parser.current()), parser.next());
      params ~= p;
      if (first)
        first = false;
    }
    return params;
  }


}
