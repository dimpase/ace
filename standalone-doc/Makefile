# ACE 4.1 manual by Colin Ramsay; XeTeX/MetaPost build integration.
textargets := $(wildcard *.tex)

all: guide

styles: styles.mp
	mpost styles

# Initial passes necessarily have unresolved citations. Retain their logs,
# show them on failure, and expose final-pass warnings to the GAP docs action.
guide: styles $(textargets) biblio.bib
	xelatex -interaction=nonstopmode -halt-on-error ace41 > ace41-pass1.log 2>&1 || { cat ace41-pass1.log; exit 1; }
	bibtex ace41
	xelatex -interaction=nonstopmode -halt-on-error ace41 > ace41-pass2.log 2>&1 || { cat ace41-pass2.log; exit 1; }
	xelatex -interaction=nonstopmode -halt-on-error ace41

clean:
	rm -f *.aux *.bbl *.blg *.dvi *.lof *.log *.lot *.pdf *.ps *.toc *.mpx
	rm -f styles*.eps *~

.PHONY: all styles guide clean
