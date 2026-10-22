# Regression for the subgroup-deletion hang reported in PR #36.
# Capture the diagnostic, assert its meaning, then test a valid query.
gap> START_TEST("aceds.tst");
gap> ReadPackage("ace", "tst/regression.g");
true
gap> G := PerfectGroup(IsSubgroupFpGroup, 2^5*60, 2);;
gap> fgens := FreeGeneratorsOfFpGroup(G);; rels := RelatorsOfFpGroup(G);;
gap> b := fgens[2];; t := fgens[4];;
gap> i := ACEStart(fgens, rels, [b,t] : workspace := "1M");;
gap> ACEStats(i).index;
80
gap> ACEDeleteSubgroupGenerators(i, [t]) = [b];
true
gap> ACEStats(i).index;
640
gap> lev := InfoLevel(InfoACE);; diagnostic := "";;
gap> output := OutputTextString(diagnostic, true);;
gap> oldOutput := InfoOutput(InfoACE);; oldWarningOutput := InfoOutput(InfoWarning);;
gap> SetInfoOutput(InfoACE, output);; SetInfoOutput(InfoWarning, output);;
gap> SetInfoLevel(InfoACE, 3);;
gap> remaining := ACEDeleteSubgroupGenerators(i, [2]);;
gap> SetInfoLevel(InfoACE, lev);; SetInfoOutput(InfoACE, oldOutput);;
gap> SetInfoOutput(InfoWarning, oldWarningOutput);; CloseStream(output);;
gap> PositionSublist(diagnostic, "ERROR") <> fail and
>    PositionSublist(diagnostic, "first argument out of range") <> fail;
true
gap> remaining = [b] and ACESubgroupGenerators(i) = [b];
true
gap> ACEStats(i).index;
640
gap> table := ACECosetTable(i);;
gap> ACE_TestTable(table, fgens, rels, [b], 640);
true
gap> ACEAddSubgroupGenerators(i, [t]) = [b,t];
true
gap> ACEStats(i).index;
80
gap> ACE_TestTable(ACECosetTable(i), fgens, rels, [b,t], 80);
true
gap> ACEQuit(i);
gap> STOP_TEST("aceds.tst", 1000000);
