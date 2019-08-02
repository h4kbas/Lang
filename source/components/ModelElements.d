module components.ModelElements;



import util.type;
import util.errors;
import util.keywords;

import structures.model: ModelElement;

import parser;

ModelElement[string] ModelElements(Parser parser, bool modify = false) {
  ModelElement[string] melements;
  if (parser.currentIf(Keywords.L_Brace)) {
    while (!parser.nextIf(Keywords.R_Brace)) {
      ModelElement e = ModelElement();
      if (parser.current.toString() !in parser.storage.models) {
        if (modify) {
          if (parser.currentIf(Keywords.Delete))
            e.type = null;
        }
        else
          throw new Error(Errors.TypeNotDefined ~ parser.current.toString());
      }
      else {
        e.type = parser.getModel(parser.current);
      }
      e.name = parser.next;
      melements[e.name.toString()] = e;
      if (parser.currentIf(Type.EOF))
        throw new Error(Errors.RightBraceExpected);
    }
    return melements;
  }
  else
    throw new Error(Errors.LeftBraceExpected);
}
