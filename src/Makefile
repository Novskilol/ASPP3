CC 		= gcc -g -Wall
LIBS 	= -lfl -ly

all: grammar.tab.c lex.yy.c commun.c
	$(CC) grammar.tab.c lex.yy.c commun.c -o doc_html $(LIBS)
	mv doc_html ../bin

grammar.tab.c: commun.h
	bison -d -v grammar.y

lex.yy.c: commun.h
	flex grammar.l

commun.c: commun.h

symboleTable.c: symboleTable.h

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/doc_html
