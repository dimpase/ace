#############################################################################
####
##
#W  general.gi              ACE Share Package                Alexander Hulpke
#W                                                                Greg Gamble
##
##  This file installs mainly non-interactive ACE  variables  and  functions.
##  Though Alexander will barely recognise it,  some  of his ideas are  still
##  present.
##    
#H  @(#)$Id$
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.general_gi :=
    "@(#)$Id$";


#############################################################################
####
##
#V  ACETCENUM . . . . . . . .  The ACE version of the coset enumerator TCENUM
##  . . . .  CosetTableFromGensAndRels is set to ACECosetTableFromGensAndRels
##
InstallValue(ACETCENUM, rec(
  name := "ACE (Advanced Coset Enumerator)",
  CosetTableFromGensAndRels := ACECosetTableFromGensAndRels
));

#############################################################################
####
##
#F  InfoACELevel . . . . . . . . . . . . . . .  Get the InfoLevel for InfoACE
##
##
InstallGlobalFunction(InfoACELevel, function()
  return InfoLevel(InfoACE);
end);

#############################################################################
####
##
#F  SetInfoACELevel . . . . . . . . . . . . . . Set the InfoLevel for InfoACE
##
##
InstallGlobalFunction(SetInfoACELevel, function(arg)
  if IsEmpty(arg) then
    SetInfoLevel(InfoACE, 1);     # Set to default level
  else
    SetInfoLevel(InfoACE, arg[1]);
  fi;
end);

#############################################################################
####
##
#F  CALL_ACE . . . . . . . . . Called by ACECosetTable, ACEStats and ACEStart
##
##
InstallGlobalFunction(CALL_ACE, function(ACEfname, fgens, rels, sgens)
local optnames, echo, infile, instream, outfile, ToACE, gens, acegens, 
      lenlex, enforceAsis, ignored;

  if ValueOption("aceexampleoptions") = true and
     IsBound(ACEData.aceexampleoptions) then
    SANITISE_ACE_OPTIONS(OptionsStack[ Length(OptionsStack) ],
                         ACEData.aceexampleoptions);
    PushOptions(ACEData.aceexampleoptions);
    Unbind(ACEData.aceexampleoptions);
    ACEData.options := OptionsStack[ Length(OptionsStack) ];
    PopOptions();
    OptionsStack[ Length(OptionsStack) ] := ACEData.options;
    Unbind(ACEData.options);
  fi;
  optnames := ACE_OPT_NAMES();
  # We have hijacked ACE's echo option ... we don't actually pass it to ACE
  echo := ACE_VALUE_ECHO(optnames);

  if ForAny(fgens, i -> NumberSyllables(i)<>1 or ExponentSyllable(i, 1)<>1) then
    Error("first argument not a valid list of group generators");
  fi;

  if echo > 0 then
    Print(ACEfname, " called with the following arguments:\n");
    Print(" Group generators : ", fgens, "\n");
    Print(" Group relators : ", rels, "\n");
    Print(" Subgroup generators : ", sgens, "\n");
  fi;
  
  if ACEfname = "ACEStart" then
    instream := InputOutputLocalProcess(ACEData.tmpdir, ACEData.binary, []);
    FLUSH_ACE_STREAM_UNTIL(instream, 4, 4, READ_NEXT_LINE, 
                           line -> line{[3..6]} = "name");
    ToACE := function(list) INTERACT_TO_ACE_WITH_ERRCHK(instream, list); end;
  else 
    if ACEfname = "ACECosetTableFromGensAndRels" then
      # If option "aceinfile" is set we only want to produce an ACE input file
      infile := VALUE_ACE_OPTION(optnames, ACEData.infile, "aceinfile");
      lenlex := VALUE_ACE_OPTION(optnames, false, "lenlex");
    elif ACEfname = "ACEStats" then
      infile := ACEData.infile; # If option "aceinfile" is set ... we ignore it
    fi;
    instream := OutputTextFile(infile, false);
    ToACE := function(list) WRITE_LIST_TO_ACE_STREAM(instream, list); end;
  fi;
  outfile := VALUE_ACE_OPTION(optnames, ACEData.outfile, "aceoutfile");

  # Define the group generators ACE will use
  gens := TO_ACE_GENS(fgens);
  ToACE([ "Group Generators: ", gens.toace, ";"]);
  acegens := gens.acegens;

  # Define the group relators ACE will use
  if ACEfname <> "ACECosetTableFromGensAndRels" or not lenlex or
     IsACEGeneratorsInPreferredOrder(fgens, rels) 
  then
    ToACE([ "Group Relators: ", ACE_WORDS(rels, fgens, acegens), ";" ]);
    enforceAsis := false;
  else
    ToACE([ "Group Relators: ", acegens[1], acegens[1], ", ",
            ACE_WORDS(Filtered(rels, rel -> rel <> fgens[1]^2), 
                      fgens, acegens), 
            ";" ]);
    enforceAsis := true;
  fi;

  # Define the subgroup generators ACE will use
  ToACE([ "Subgroup Generators: ", ACE_WORDS(sgens, fgens, acegens), ";" ]);

  if ACEfname  = "ACECosetTableFromGensAndRels" then
    ignored := [ ];
  else 
    ignored := [ "aceinfile" ];
  fi;
  if ACEfname  = "ACEStart" then
    Add(ignored, "aceoutfile");
  fi;

  PROCESS_ACE_OPTIONS(
      ACEfname, optnames, optnames, echo, ToACE, 
      rec(group      := ACE_ERRORS.argnotopt, # disallowed options
          generators := ACE_ERRORS.argnotopt,
          relators   := ACE_ERRORS.argnotopt), 
      ignored
      );
              
  if ACEfname <> "ACEStart" then
    # Direct ACE output to outfile if called via
    # ACECosetTableFromGensAndRels or ACEStats
    ToACE([ "Alter Output:", outfile, ";" ]);

    if enforceAsis then
      ToACE([ "Asis: 1;" ]);
    fi;

    ToACE([ "Start;" ]); # (one of) the ACE directives that initiate
                         # an enumeration

    if ACEfname = "ACECosetTableFromGensAndRels" then
      if lenlex then
        ToACE([ "Standard;" ]);
      fi;
      ToACE([ "Print Table;" ]);
    fi;

    if ACEfname = "ACEStats" or infile = ACEData.infile then
      # Run ACE on the constructed infile
      # ... the ACE output will appear in outfile 
      #     (except for the banner which is directed to ACEData.banner)
      Exec(Concatenation(ACEData.binary, "<", infile, ">", ACEData.banner));
    fi;
  fi;

  if ACEfname = "ACECosetTableFromGensAndRels" then
    return rec(acegens := acegens, 
               infile := infile, 
               outfile := outfile,
               silent := VALUE_ACE_OPTION(optnames, false, "silent"));
  elif ACEfname = "ACEStats" then
    return outfile;
  else # ACEfname = "ACEStart"
    Add(ACEData.io, 
        rec(args := rec(fgens := fgens, rels := rels, sgens := sgens),
            options := ACE_OPTIONS(),
            acegens := acegens, 
            stream := instream));
    return Length(ACEData.io);
  fi;
end);

#############################################################################
####
##
#F  ACECosetTableFromGensAndRels . . . . . . .  Non-interactive ACECosetTable
##
##
InstallGlobalFunction(ACECosetTableFromGensAndRels, function(fgens, rels, sgens)
  # Use ACECosetTable non-interactively
  return ACECosetTable(fgens, rels, sgens);
end);

#############################################################################
####
##
#F  IsACEGeneratorsInPreferredOrder . . . . . Returns true if the  generators
##  . . . . . . . . . . . . . . . . . . . . . gens are already in  the  order
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  preferred by ACE
##
##  For a presentation with more than one generator, the first  generator  of
##  which is an involution and the second is not, ACE prefers to  switch  the
##  first two generators. IsACEGeneratorsInPreferredOrder returns true if the
##  order of the generators gens would not  be  changed  by  ACE  and  false,
##  otherwise. When necessary, the argument rels (the  relators)  is  scanned
##  for relators that determine  whether  or  not  gens[1]  and  gens[2]  are
##  involutions.
##
##  If IsACEGeneratorsInPreferredOrder would return true, it is  possible  to
##  enforce a user's order of the generators within ACE, by  enforcing  ACE's
##  `asis' option and passing the relator,  that  determines  gens[1]  is  an
##  involution,  explicitly  to  ACE   as:   gens[1]*gens[1]   (rather   than
##  gens[1]^2).
##
InstallGlobalFunction(IsACEGeneratorsInPreferredOrder, function(arg)
local ioIndex, gens, rels;

  if Length(arg) < 2 then
    ioIndex := ACE_IOINDEX(arg);
    gens := ACEGroupGenerators(ioIndex);
    rels := ACERelators(ioIndex);
  elif Length(arg) = 2 then
    gens := arg[1];
    rels := arg[2];
  else
    Error("Expected at most 2 arguments, not ", Length(arg), " arguments.");
  fi;

  if Length(gens) = 1 or not ForAny(rels, rel -> rel = gens[1]^2) then
    return true;
  else
    return ForAny(rels, rel -> rel = gens[2]^2);
  fi;
end);

#############################################################################
####
##
#F  ACE_READ_AS_FUNC  . . . . . . . . . . . . . . . Variant of ReadAsFunction 
##  . . . . . . . . . . . .  that allows the passing of the function argument
##  . . . . . . . . . . . . . . . . . . . . ACEfunc to ReadAsFunction(file)()
##
##
InstallGlobalFunction(ACE_READ_AS_FUNC, function(file, ACEfunc)
  local line, instream, rest;

  instream := InputTextFile(file);
  # We don't want the user to see this ... so we flush at InfoACE level 10.
  line := FLUSH_ACE_STREAM_UNTIL( instream, 10, 10, ReadLine,
                                  line -> line{[1..5]} = "local" );
  return ReadAsFunction(
             InputTextString(
                 Concatenation([
                     ReplacedString(line, ";", ", ACEfunc;"),
                     "ACEfunc := ", NameFunction(ACEfunc), ";",
                     ReadAll(instream)
                     ]) ) )();
end);

#############################################################################
####
##
#F  ACEExample  . . . . . . . .  Read an example from the examples directory.
##  . . . . . . . . . . . . . . . If given the name of a file in the examples 
##  . . . . . . . . . . . . . . . directory,  that file is displayed and read
##  . . . . . . . . . . . . . . . as a function. Otherwise, if no argument is
##  . . . . . . . . . . . . . . . given or the name given is for a file  that
##  . . . . . . . . . . . . . . . does not exist,  the file  "examples/index"
##  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . is displayed.
##
InstallGlobalFunction(ACEExample, function(arg)
    local name, file, instream, line, ACEfunc,
          EnquoteIfString, optnames, lastoptname, optname;

    if IsEmpty(arg) then
      name := "index";
    else
      name := arg[1];
      if Length(arg) > 1 then
        ACEfunc := arg[2];
      else
        ACEfunc := ACECosetTableFromGensAndRels;
      fi;
      if not IsEmpty(OptionsStack) then
        ACEData.aceexampleoptions := OptionsStack[ Length(OptionsStack) ];
        PopOptions();
        PushOptions( rec(aceexampleoptions := true) );
      fi;
    fi;
    file := Filename( DirectoriesPackageLibrary( "ace", "examples"), name );
    if file = fail then
      Info(InfoACE + InfoWarning, 1,
           "Sorry! There is no ACE example file with name `", name, "'");
      name := "index";
      file := Filename( DirectoriesPackageLibrary("ace", "examples"), name );
    fi;
    # Display file ... after a few minor modifications
    instream := InputTextFile(file);
    if name <> "index" then
      line := FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine,
                                      line -> line{[1..5]} = "local" );
      Info(InfoACE, 1,
           "#", line{[Position(line, ' ')..Position(line, ';') - 1]},
           " are local to ACEExample");
      line := FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine, 
                                      line -> line{[1..6]} = "return" );
      Info(InfoACE, 1, 
           CHOMP(ReplacedString(line, "return ACEfunc", NameFunction(ACEfunc)))
           );
      if IsBound(ACEData.aceexampleoptions) then
        line := FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine, 
                                        line -> ForAny(
                                                    [1..Length(line)],
                                                    i -> line{[i..i+1]} = ");"
                                                    ) );
        Info(InfoACE, 1, CHOMP(ReplacedString(line, ");", ", ")));
        Info(InfoACE, 1, "    # User Options");
        optnames := ShallowCopy( RecNames(ACEData.aceexampleoptions) );
        lastoptname := optnames[ Length(optnames) ];
        Unbind(optnames[ Length(optnames) ]);

        EnquoteIfString := function(optval)
        # Puts quotes around optval if it's a string
          if IsString(optval) then
            return Concatenation(["\"", optval, "\""]);
          else
            return optval;
          fi;
        end;

        for optname in optnames do
          Info(InfoACE, 1, "      ", optname, " := ", 
                           EnquoteIfString(
                               ACEData.aceexampleoptions.(optname) ), ",");
        od;
        Info(InfoACE, 1, "      ", lastoptname, " := ", 
                         EnquoteIfString(
                             ACEData.aceexampleoptions.(lastoptname) ), ");");
      fi;
    fi;
    FLUSH_ACE_STREAM_UNTIL( instream, 1, 10, ReadLine, line -> line = fail );
    if name <> "index" then
      return ACE_READ_AS_FUNC(file, ACEfunc);
    fi;
end);

#############################################################################
####
##
#F  CallACE . . . . . . . . . . . . . . . . . . . . . . . . . . .  deprecated
##
InstallGlobalFunction(CallACE, function(arg)

  Error("CallACE is deprecated: Use `ACECosetTableFromGensAndRels' or\n",
        "`ACECosetTable'.\n");
end);

#E  general.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
