module util.log;

import std.stdio: writef;

void log(T)(T obj, int Ident = 1)
{
  import std.array: replicate;
  import std.stdio: writefln;
	string Idnt = replicate(" ", Ident * 2);
  if(obj is null) return;
	static if (is(T == struct) || is(T == class))
	{
		writefln("{");
		foreach (i, _; obj.tupleof)
		{	
			auto Value = obj.tupleof[i];
			auto Key = obj.tupleof[i].stringof[4 .. $];
			alias ST = typeof(Value);
			static if (is(ST
			 == struct) || is(ST == class)){
				writef("%s%s: %s ", Idnt, Key, Value);
				log(Value, Ident+1);
			}
			else
				writefln("%s%s: %s,", Idnt, Key, Value);
		}
		writefln("%s}", replicate(" ", (Ident - 1) * 2));
	}
	else
	{
		writefln(obj);
	}
}
