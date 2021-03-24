module interpreter;

import std.stdio;
import assembly;
import util.bytecode;
import util.token;
import std.conv: to;
import std.range.primitives: popBack;

import structures.variable;
import structures.block;

import util.errors;
class Interpreter{
  Token[] stack;

  void interpret(Assembly assembly, ulong mainblock){
    Token var2, var1;
    Block blockMain = assembly.blocks[mainblock-1];
    if(!blockMain)
      throw new Exception(Errors.BlockNotDefined);
    foreach(ins; blockMain.Code){
      var2 = null; var1 = null;
      final switch(ins.operator){
        case ByteCode.Load:
          if(Variable v = blockMain.getVariable(ins.operands[0]))
            stack~=new Token(v.value);
          else
            throw new Exception(Errors.VariableNotDefined);
        break;
        case ByteCode.Push:
          stack~=ins.operands[0];
        break;
        case ByteCode.Assign:
          var1 = pop();
          if(Variable v = blockMain.getVariable(ins.operands[0])){
            v.value = var1.value;
          }
          else
            throw new Exception(Errors.VariableNotDefined);
        break;

        case ByteCode.Inc:
          if(Variable v = blockMain.getVariable(ins.operands[0])){
            v.value++;
          }
          else{
            ins.operands[0].prepValue();
            ins.operands[0].value++;
          }
        break;
        case ByteCode.Dec:
          if(Variable v = blockMain.getVariable(ins.operands[0])){
            v.value--;
          }
          else{
            ins.operands[0].prepValue();
            ins.operands[0].value--;
          }
        break;

        case ByteCode.Div:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value / var1.value);
        break;
        case ByteCode.Mul:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value * var1.value);
        break;

        case ByteCode.Add:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value + var1.value);
        break;
        case ByteCode.Sub:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value - var1.value);
        break;

        case ByteCode.Not:
          var1 = pop();
          stack~=new Token(!var1.value);
        break;
        case ByteCode.And:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value && var1.value);
        break;
        case ByteCode.Or:
          var1 = pop();
          var2 = pop();
          stack~=new Token(var2.value || var1.value);
        break;
        case ByteCode.Xor:

        break;

        case ByteCode.Br:

        break;
      }
      import std.algorithm.iteration: each;
      write(ins.operator, " ");
      foreach(x; ins.operands) {x.prepValue(); write("{", x.text, ", ", x.value, "} ");}
      write("> "); foreach(x; stack) {x.prepValue(); write("{", x.text, ", ", x.value, "} ");} writeln();
    }
    write("> "); foreach(x; stack) {x.prepValue(); write("{", x.text, ", ", x.value, "} ");} writeln();
  }

  Token pop(){
    Token temp = stack[$ - 1]; 
    temp.prepValue();
    stack.popBack();
    return temp;
  }
}