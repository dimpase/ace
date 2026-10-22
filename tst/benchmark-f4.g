# Opt-in research run. Supply the original presentation via ACE_F4_INPUT.
# This file is not a TestDirectory test and does not assert the conjecture.
if LoadPackage("ace") <> true then Error("ACE is required"); fi;
if not IsBound(GAPInfo.SystemEnvironment.ACE_F4_INPUT) then
    Error("Set ACE_F4_INPUT to the supplied f4_leaf.g");
fi;
oldTCENUM := TCENUM;;
Read(GAPInfo.SystemEnvironment.ACE_F4_INPUT);
TCENUM := oldTCENUM;;
D := F4LeafPresentation(false);;
Print("Presentation U_*; relators=", Length(D.rels),
      "; expected (unproved) index=", D.expectedIndex, "\n");
Print("GAP=", GAPInfo.Version, "; package=", ACEPackageVersion(), "\n",
      "Package path=", DirectoriesPackageLibrary("ace", ""), "\n",
      "Binary path=", ACEData.binary, "; banner version=", ACEData.version, "\n",
      "Strategy=default; workspace=128000000 entries; external timeout required\n");
SetInfoLevel(InfoACE, 3); # retain progress counters if the external deadline wins
result := ACEStats(D.fgens, D.rels, D.sgens
                   : workspace := 128000000, messages := 1000000);;
Print("Final statistics: ", result, "\n");
if result.index = 0 then
    Print("INCOMPLETE: this run does not decide the conjectured index.\n");
else
    Print("COMPLETED index=", result.index, "\n");
fi;
QUIT;
