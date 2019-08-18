module components.Scope;


import util.errors;
import util.keywords;

import components.Statement;

import structures.block;
import parser;
import util.log;
import std.stdio;

Block Scope(Parser parser, uint depth) {
  
  if (!parser.nextIf(Keywords.L_Brace))
    throw new Exception(Errors.LeftBraceExpected);
  parser.scopedepth++;
  Block currentBlock = parser.assembly.currentBlock;
  Block newBlock = parser.assembly.NewBlock(parser.scopedepth);
  if(currentBlock){
    newBlock.parent = currentBlock.depth < newBlock.depth ? currentBlock : currentBlock.parent;
  }
  
  while (!parser.nextIf(Keywords.R_Brace) && parser.scopedepth != depth) {
    Statement(parser);
  }
  if (!parser.currentIf(Keywords.R_Brace))
    throw new Exception(Errors.RightBraceExpected);
  parser.scopedepth--;
  return newBlock;
}

