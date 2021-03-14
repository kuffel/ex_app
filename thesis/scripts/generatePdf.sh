#!/bin/bash
# runme if you want to generate the pdf file

cd ../src

# 1. Generiert das Dokument mit Fragezeichen anstelle von Zitaten
pdflatex thesis.tex
# 2. Dies wird die .bib Datei verarbeiten, und das Dokument mit Zitatinformationen anreichern – Beachten Sie dass Ihre .bib Datei änders heißen kann, dann muss der Befehl Hauptdatei  entsprechend angepasst werden.
bibtex thesis
# 3. aktualisiert den Index
makeindex thesis.nlo -s latex_einstellungen/abkuezungen/nomencl.ist -o thesis.nls
# 4. Verarbeitet die Datein nochmals und inkludiert die Zitate
pdflatex thesis.tex
# 5. nochmal, um sicher zu gehen, u.a. falls sich durch die Zitate die Seitennummerierung geändert hat
pdflatex thesis.tex


## Aufräumen...
rm -f *.aux *.dvi *.log *.lot *.lol *.lof *.nls *.ilg *.nlo *.idx *.out *.toc *.ist *.glo *.blg
cd latex_einstellungen
rm -f *.aux