module components.Definition;

import util.keywords;

import structures.model: Model;
import util.errors;
import util.component;

class Definition: Component {
  
  override void parse() {
    //Extend
    if (parser.currentIf(Keywords.Modify)) {
      if (parser.next.toString() !in parser.storage.models)
        throw new Error(Errors.CantModifyUndefinedModel);
      Model m = parser.storage.models[parser.current.toString()];
      parser.next();
      auto elements = parser.ModelElements(true);
      foreach (name, e; elements) {
        if (e.type !is null) {
          if (name !in m.elements) {
            m.elements[name] = e;
          }
          else
            throw new Error(Errors.CantChangeAlreadyDefinedElement);
        }
        else {
          if (name in m.elements)
            m.elements.remove(name);
          else
            throw new Error(Errors.CantDeleteUndefinedElement);
        }
      }
    }
    else {
      if (parser.current.toString() in parser.storage.models)
        throw new Error(Errors.ModelAlreadyDeclared ~ parser.current.toString());
      if (parser.currentIf(Keywords.Delete))
        throw new Error(Errors.DeleteReserved);
      Model m = new Model(parser.current.toString());
      //Inheritance
      if (parser.nextIf(Keywords.Colon)) {
        if (parser.next.toString() in parser.storage.models) {
          m.parent = parser.storage.models[parser.current.toString()];
          m.elements = m.parent.elements.dup;
          parser.next();
        }
        else
          throw new Error(Errors.ParentModelNotDefined);
      }
      auto elements = parser.ModelElements(true);
      foreach (name, e; elements) {
        if (e.type !is null) {
          if (name !in m.elements) {
            m.elements[name] = e;
          }
          else
            throw new Error(Errors.CantChangeAlreadyDefinedElement);
        }
        else {
          if (name in m.elements)
            m.elements.remove(name);
          else
            throw new Error(Errors.CantDeleteUndefinedElement);
        }
      }
      parser.storage.models[m.name.toString()] = m;
    }
  }

}