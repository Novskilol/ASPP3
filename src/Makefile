CC = gcc -g -Wall
LIBS = -lfl -ly -lm

all: grammar.tab.c lex.yy.c commun/commun.c symboleTable/symboleTable.c symboleStack/symboleStack.c symboleList/symboleList.c
	$(CC) grammar.tab.c lex.yy.c commun/commun.c symboleTable/symboleTable.c symboleStack/symboleStack.c symboleList/symboleList.c -o doc_html $(LIBS)
	mv doc_html ../bin

grammar.tab.c: commun/commun.h
	bison -d -v grammar.y

lex.yy.c: commun/commun.h
	flex grammar.l

commun/commun.c: commun/commun.h

symboleList/symboleList.c: symboleList/symboleList.h

symboleStack/symboleStack.c: symboleStack/symboleStack.h

symboleTable/symboleTable.c: symboleTable/symboleTable.h symboleStack/symboleStack.h symboleList/symboleList.h

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/doc_html symboleTable/testSymboleTable symboleStack/testSymboleStack symboleList/testSymboleList *.o 
