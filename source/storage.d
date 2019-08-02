module storage;

import structures.model;
import structures.func;
import structures.variable;

import util.token;
import util.errors;

class Storage{
  Model[string] models;
  Func[string] functions;

  Model getModel(Token s, bool bypass = true) {
    if (s.toString() in this.models) {
      return this.models[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.ModelNotDefined ~ s.toString());
    else
      return null;
  }

  Func getFunc(Token s, bool bypass = true) {
    if (s.toString() in this.functions) {
      return this.functions[s.toString()];
    }
    if (bypass)
      throw new Exception(Errors.FuncNotDefined ~ s.toString());
    else
      return null;
  }

}