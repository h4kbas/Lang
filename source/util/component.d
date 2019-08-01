module util.component;

import parser: Parser;

abstract class Component{
  Parser parser;

  void parse(){}
  void parse(uint depth){}
  
  Component component(string name){
    return this.parser.component(name);
  }
}