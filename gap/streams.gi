#############################################################################
####
##
#W  streams.gi              ACE Share Package                     Greg Gamble
##
##  This file installs non-user functions used in interactions with streams.
##    
#H  @(#)$Id$
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.streams_gi :=
    "@(#)$Id$";


#############################################################################
####
##
#F  ACE_JOIN  . . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . .  concatenates strings interspersed with separator
##  . . . . . . . . . . . . . . .  e.g. ACE_JOIN(["a", "b"], ",") gives "a,b"
##
InstallGlobalFunction(ACE_JOIN, function(strings, separator)
  if IsEmpty(strings) then
    return "";
  else
    return Concatenation(
               Concatenation(
                   Concatenation(
                       List(strings{[1 .. Length(strings) - 1]},
                            s -> [ s, separator ])
                       ),
                   [ strings[ Length(strings) ] ]
                   )
               );
  fi;
end);

#############################################################################
####
##
#F  ACE_STRINGS . . . . . . . . . . . . . . . . . . . . . . Internal function
##  . . . . . . . . . . . . . . . . . . . . returns list as a list of strings 
##
InstallGlobalFunction(ACE_STRINGS, 
  list -> List(list, x -> String(x))
);

#############################################################################
####
##
#F  ACE_EVAL_STRING_EXPR  . . . . . . . . . . . . . . . . . evaluate a string
##  . . . . . . . . . . . . . . . . passes string through an  InputTextStream
##  . . . . . . . . . . . . . . . . . . . . . . . . so that GAP interprets it
##
InstallGlobalFunction(ACE_EVAL_STRING_EXPR, function(string)
local expr, temp;

  temp := TemporaryGlobalVarName();
  Read( InputTextString(Concatenation( temp, ":=", string, ";" )) );
  expr := ValueGlobal(temp);
  UnbindGlobal(temp);
  return expr;
end);

#############################################################################
####
##
#F  CHOMP . . . . . . . . . Return string minus a trailing '\n' if it has one
##  . . . . . . . . . . . . . . . . . . . . . (named after the Perl function)
##
InstallGlobalFunction(CHOMP, function(string)

  if string<>fail and string <> "" and string[Length(string)] = '\n' then
    return string{[1 .. Length(string) - 1]};
  else
    return string;
  fi;
end);

#############################################################################
####
##
#F  READ_ALL_LINE . . . . . . . . .  Read a complete line (i.e. until a '\n')
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  or return fail 
##
##  Essentially, like ReadLine but does not return a line fragment ... if the
##  initial ReadLine call doesn't return fail, it waits until it has all  the
##  line before returning.
##
InstallGlobalFunction(READ_ALL_LINE, function(iostream)
local line, moreOfline;

  line := ReadLine(iostream); # If we get fail here, we just return
  if line <> fail then
    while line[Length(line)] <> '\n' do
      Sleep(1);
      moreOfline := ReadLine(iostream);
      if moreOfline <> fail then
        Append(line, moreOfline);
      fi;
    od;
  fi;
  return line;
end);

#############################################################################
####
##
#F  READ_NEXT_LINE . . . . . . . . Read a complete line but never return fail
##
##  Essentially, like  READ_ALL_LINE  but we know there is a complete line to 
##  be got ... so we wait for it, before returning.
##
InstallGlobalFunction(READ_NEXT_LINE, function(iostream)
local line;

  line := READ_ALL_LINE(iostream);
  while line = fail do
    Sleep(1);
    line := READ_ALL_LINE(iostream);
  od;
  return line;
end);

#############################################################################
####
##
#F  WRITE_LIST_TO_ACE_STREAM . . . . . . . . . . . . . . .  Internal function
##
##  Writes list to stream and with a `ToACE> '  prompt  to  Info  at  InfoACE
##  level 4 and returns true if successful and fail otherwise.
##
InstallGlobalFunction(WRITE_LIST_TO_ACE_STREAM, function(stream, list)
local string;

  if not IsOutputTextStream(stream) and IsEndOfStream(stream) then
    Info(InfoACE + InfoWarning, 1, "Sorry. Process stream has died!");
    Info(InfoACE + InfoWarning, 1, 
         "You might like to try using 'ACEResurrect(<i>);'");
    return fail;
  fi;
  string := Concatenation( List(list, x -> String(x)) );
  Info(InfoACE, 4, "ToACE> ", string);
  return WriteLine(stream, string);
end);

#E  streams.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
