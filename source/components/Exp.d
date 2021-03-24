module components.Exp;

import std.range.primitives : popBack;
import std.algorithm.mutation : reverse;
import std.algorithm.searching;


import util.token;
import util.keywords;

import std.traits;
import std.format;

import parser;

   
  Token[] Operands;
  Token[] Operators;
 
  void Exp(Parser parser) {
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
      CalcIt(parser);
    }
    else if (!isOperator(parser.current)) {
      Operands ~= parser.current;
    }
  }

  uint precedence(Token t) {
    if ([Keywords.PPlus, Keywords.MMinus].canFind(t.text))
      return 10;
    if ([Keywords.Not].canFind(t.text))
      return 9;
    if ([Keywords.Times, Keywords.Divide].canFind(t.text))
      return 8;
    else if ([Keywords.Plus, Keywords.Minus].canFind(t.text))
      return 7;
    else if ([Keywords.BAnd].canFind(t.text))
      return 6;
    else if ([Keywords.Xor].canFind(t.text))
      return 5;
    else if ([Keywords.BOr].canFind(t.text))
      return 4;
    else if ([Keywords.And].canFind(t.text))
      return 3;
    else if ([Keywords.Or].canFind(t.text))
      return 2;
    else if ([Keywords.Assign, Keywords.AssignTimes, Keywords.AssignDivide, 
              Keywords.AssignPlus, Keywords.AssignMinus].canFind(t.text))
      return 1;
    else
      return 0;
  }
  bool isUnary(Token t) {
    return [Keywords.Not, Keywords.PPlus, Keywords.MMinus].canFind(t.text);
  }

  bool isOperator(Token x) {
    return [
      Keywords.PPlus, Keywords.MMinus,
      Keywords.Not,
      Keywords.Times, Keywords.Divide,
      Keywords.Plus, Keywords.Minus,
      Keywords.BAnd,
      Keywords.Xor,
      Keywords.BOr,
      Keywords.And,
      Keywords.Or,
      Keywords.Assign, Keywords.AssignTimes, Keywords.AssignDivide, 
        Keywords.AssignPlus, Keywords.AssignMinus
    ].canFind(x.text);
  }

  void CalcIt(Parser parser) {
    bool first = true;
    Token left, right, op;
    while (Operands.length > 0) {
      if (!isOperator(Operands[$ - 1])) {
        Operators ~= Operands[$ - 1];
        Operands.popBack();
      }
      else {
        op = Operands[$ - 1];
        import std.stdio: writeln;
        if (first) {
          if( (op != Keywords.Assign)||((op == Keywords.Assign ) && (Operands.length == 1)))
            parser.assembly.Push(Operators[$ - 1]);
          right = Operators[$ - 1];
          Operators.popBack();
        }
        if(!isUnary(op)){
          if(op != Keywords.Assign)
            parser.assembly.Push(Operators[$ - 1]);
          left = Operators[$ - 1];
          Operators.popBack();
        }
        
        final switch(op.text) {
          case Keywords.Not:
            parser.assembly.Not();
            break;

          case Keywords.PPlus:
            parser.assembly.PPlus(right);
            break;
          case Keywords.MMinus:
            parser.assembly.MMinus(right);
            break;
          
          case Keywords.Times:
            parser.assembly.Times();
            break;
          case Keywords.Divide:
            parser.assembly.Divide();
            break;
            
          case Keywords.Plus:
            parser.assembly.Plus();
            break;
          case Keywords.Minus:
            parser.assembly.Minus();
            break;

          case Keywords.BAnd:
            parser.assembly.BAnd();
            break;
          case Keywords.Xor:
            parser.assembly.Xor();
            break;
          case Keywords.BOr:
            parser.assembly.BOr();
            break;
          case Keywords.And:
            parser.assembly.And();
            break;
          case Keywords.Or:
            parser.assembly.Or();
            break;
          case Keywords.Assign:
            parser.assembly.Assign(left);
            break;
          case Keywords.AssignTimes:
            parser.assembly.AssignTimes(left);
            break;
          case Keywords.AssignDivide:
            parser.assembly.AssignDivide(left);
            break; 
          case Keywords.AssignPlus:
            parser.assembly.AssignDivide(left);
            break; 
          case Keywords.AssignMinus:
            parser.assembly.AssignDivide(left);
            break;
        }
        Operands.popBack();
        first = false;
      }
    }
  }