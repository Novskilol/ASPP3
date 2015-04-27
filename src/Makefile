CC 		= gcc -g -Wall
LIBS 	= -lfl -ly

all: grammar.tab.c lex.yy.c commun/commun.c stack/stack.c
	$(CC) grammar.tab.c lex.yy.c commun/commun.c stack/stack.c -o doc_html $(LIBS)
	mv doc_html ../bin

grammar.tab.c: commun/commun.h
	bison -d -v grammar.y

lex.yy.c: commun/commun.h
	flex grammar.l

commun/commun.c: commun/commun.h

stack/stack.c: stack/stack.h

symboleTable.c: symboleTable.h

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/doc_html
