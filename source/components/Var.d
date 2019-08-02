module components.Var;

import parser;
import structures.variable: Variable;

void Var(Parser parser) {
  Variable v = new Variable(parser.storage.getModel(parser.current), parser.next);
  parser.assembly.currentBlock.addVariable(v);
}