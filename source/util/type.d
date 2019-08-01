module util.type;

enum Type
{
  None = -2,
  EOL = -1,
  EOF = 0,
  SOF = 0,
  Ident,
  Str,
  Int,
  Sym
};
