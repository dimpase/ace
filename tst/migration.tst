gap> START_TEST("migration.tst");
gap> ReadPackage("ace", "tst/regression.g");
true
gap> fixture := ACE_TestExample("A5");;
gap> i := ACEStart(fixture.fgens, fixture.rels, [] : workspace := "1M");;
gap> ACEBinaryVersion() = ACEBinaryVersion(i) and IsString(ACEBinaryVersion(i));
true
gap> ACEStats(i : time := 1);
Error, ACE 4.1 no longer supports option `time'

gap> ACEStats(i : ai := "missing.in");
Error, ACE 4.1 no longer supports option `ai'

gap> SetACEOptions(i, rec(pmod := 2));
Error, ACE 4.1 no longer supports option `pmod'

gap> ACEStats(i : aceoutfile := "unused.out");
Error, ACE 4.1 no longer supports option `aceoutfile'

gap> ACEStats(i : stats);
Error, ACE 4.1 no longer supports option `stats'

gap> ACEStats(i : dump);
Error, ACE 4.1 no longer supports option `dump'

gap> ACEStats(i : hole := 1);
Error, ACE 4.1 no longer supports option `hole'

gap> ACEStats(i : print := [1,2,3]);
Error, ACE 4.1 print expects at most two integers

gap> ACEDisplayCosetTable(i, [1,2,3]);
Error, ACE 4.1 print expects at most two integers

gap> ACEStats(i : pd := 2);
Error, ACE 4.1 pdefinitions expects a Boolean or 0/1

gap> ACEDumpVariables(i);
Error, ACEDumpVariables is unavailable with ACE 4.1; use ACEParameters

gap> ACEDumpStatistics(i);
Error, ACEDumpStatistics is unavailable with ACE 4.1; use ACEStats

gap> ACEStats(i).index = 60 and not IsBound(GetACEOptions(i).time);
true
gap> ACEStats(i : pd := false).index;
60
gap> ACEParameters(i).pdefinitions;
0
gap> ACEStats(i : pdefinitions := true).index;
60
gap> params := ACEParameters(i);;
gap> params.pdefinitions = 1 and params.workspace = "1M" and not IsBound(params.time);
true
gap> captured := "";; output := OutputTextString(captured, true);;
gap> lev := InfoLevel(InfoACE);; oldOutput := InfoOutput(InfoACE);;
gap> oldWarningOutput := InfoOutput(InfoWarning);;
gap> SetInfoLevel(InfoACE, 3);; SetInfoOutput(InfoACE, output);;
gap> SetInfoOutput(InfoWarning, output);;
gap> for detail in [0..5] do ACEStats(i : sr := detail); od;
gap> ACEStats(i : options);;
gap> ACEDisplayCosetTable(i, [-1,-3]);
gap> SetInfoLevel(InfoACE, lev);; SetInfoOutput(InfoACE, oldOutput);;
gap> SetInfoOutput(InfoWarning, oldWarningOutput);; CloseStream(output);;
gap> PositionSublist(captured, "Run Parameters") <> fail and
>    PositionSublist(captured, "ERROR") = fail and PositionSublist(captured, "rep've") <> fail;
true
gap> ACEStats(i).index;
60
gap> ACE_TestTable(ACECosetTable(i), fixture.fgens, fixture.rels, [], 60);
true
gap> reps := ACECosetRepresentatives(i);;
gap> Length(reps) = 60 and ACECosetRepresentative(i,2) = reps[2];
true
gap> List(reps, w -> ACETraceWord(i,1,w)) = [1..60];
true
gap> ACETransversal(i) = reps;
true
gap> ACEStats(i : ha).index;
60
gap> params := ACEParameters(i);;
gap> params.ct = 1000 and params.rt = 1;
true
gap> ACEStats(i).index;
60
gap> ACEQuit(i);
gap> STOP_TEST("migration.tst", 1000000);
