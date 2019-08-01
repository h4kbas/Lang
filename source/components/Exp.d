module components.Exp;

import std.range.primitives : popBack;
import std.algorithm.mutation : reverse;
import std.algorithm.searching;

import util.component;
import util.token;
import util.keywords;


class Exp: Component {
   
  Token[] Operands;
  Token[] Operators;
 
  override void parse() {
    if (isOperator(parser.current)) {
      while (Operators.length && precedence(parser.current) <= precedence(Operators[$ - 1])) {
        Operands ~= Operators[$ - 1];
        Operators.popBack();
      }
      Operators ~= parser.current;
    }
    else if (parser.currentIf(Keywords.L_Paren)) {
      Operators ~= parser.current;
    }
    else if (parser.currentIf(Keywords.R_Paren)) {
      while (Operators[$ - 1].text != Keywords.L_Paren) {
        Operands ~= Operators[$ - 1];
        Operators.popBack();
      }
      Operators.popBack();
    }
    else if (parser.currentIf(Keywords.SemiColon)) {
      Operands = (Operands ~ Operators.reverse()).reverse();
      Operators = [];
      CalcIt();
    }
    else if (!isOperator(parser.current)) {
      Operands ~= parser.current;
    }
  }

  uint precedence(Token t) {
    if ([Keywords.PPlus, Keywords.MMinus].canFind(t.text))
      return 8;
    if ([Keywords.Not].canFind(t.text))
      return 7;
    if ([Keywords.Times, Keywords.Divide].canFind(t.text))
      return 6;
    else if ([Keywords.Plus, Keywords.Minus].canFind(t.text))
      return 5;
    else if ([Keywords.And].canFind(t.text))
      return 4;
    else if ([Keywords.Xor].canFind(t.text))
      return 3;
    else if ([Keywords.Or].canFind(t.text))
      return 2;
    else if ([Keywords.Assign].canFind(t.text))
      return 1;
    else
      return 0;
  }

  bool isOperator(Token x) {
    return [
      Keywords.Times, Keywords.Plus, Keywords.PPlus, Keywords.Minus,
      Keywords.MMinus, Keywords.Assign, Keywords.Divide, Keywords.And,
      Keywords.Or, Keywords.Xor, Keywords.Not
    ].canFind(x.text);
  }

   void CalcIt() {
    bool first = true;
    while (Operands.length > 0) {
      if (!isOperator(Operands[$ - 1])) {
        Operators ~= Operands[$ - 1];
        Operands.popBack();
      }
      else {
        if (first) {
          parser.assembly.Push(Operators[$ - 1]);
          Operators.popBack();
        }
        parser.assembly.Push(Operators[$ - 1]);
        Operators.popBack();

        final switch (Operands[$ - 1].text) {
        case Keywords.Plus:
          parser.assembly.Add();
          break;
        case Keywords.Minus:
          parser.assembly.Sub();
          break;

        case Keywords.Times:
          parser.assembly.Mul();
          break;
        case Keywords.Divide:
          parser.assembly.Div();
          break;
        }
        Operands.popBack();
        first = false;
      }
    }
  }


}