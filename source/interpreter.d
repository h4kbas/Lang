module interpreter;

import std.stdio;
import assembly;
import util.bytecode;
import util.token;
import std.conv: to;
import std.range.primitives: popBack;

class Interpreter{
  Token[] stack;

  void interpret(Assembly assembly, ulong mainblock){
    Token var2, var1;
    writeln(stack);
    foreach(ins; assembly.blocks[mainblock-1].Code){
      var2 = null; var1 = null;
      final switch(ins.operator){
        case ByteCode.Push:
          stack~=ins.operands[0];
        break;
        case ByteCode.Assign:
          var2 = pop();
          var1.value = var2.value;
        break;

        case ByteCode.Inc:
          var1 = stack[$ - 1];
          var1.value++;
          var1.text = var1.value.to!(char[]);
        break;
        case ByteCode.Dec:
          var1 = stack[$ - 1];
          var1.value--;
          var1.text = var1.value.to!(char[]);
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
      writeln(">>> ", ins.operator, " ", ins.operands, " <<< ", stack, " var2: ", var2, " var1: ", var1);
    }
    writeln("> ", stack);
  }

  Token pop(){
    import std.string: isNumeric;
    Token temp = stack[$ - 1]; 
    if(temp.text.isNumeric)
      temp.value = temp.text.to!double;
    else
      temp.value = 0;
    stack.popBack();
    return temp;
  }
}