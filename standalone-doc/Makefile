
# Makefile for ACE 4.1xx doco, Colin Ramsay, 24 Sep 03, 25 Apr 14

styles: styles.mp
	mpost styles

dvi: 
	latex ace41

bib:
	bibtex ace41

guide:
	latex ace41
	bibtex ace41
	latex ace41

ps:
	dvips -o ace41.ps ace41

pdf: 
	gs -dSAFER -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
         -sOutputFile=ace41.pdf -sPAPERSIZE=a4 ace41.ps
clean:
	rm -f *.aux *.bbl *.blg *.dvi *.lof *.log *.lot *.pdf *.ps *.toc *.mpx
	rm -f styles.0 styles.1 styles.2 styles.5 styles.6 styles.7 styles.8
	rm -f *~


