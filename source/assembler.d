module assembler;

class Assembler
{
  char[] code;

  void insert(string s){
    this.code ~= s;
  }
  void start_if(){
    this.insert("<Start If>");
  }
}
