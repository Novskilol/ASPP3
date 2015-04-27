CC = gcc -g -Wall
LIBS = -lfl -ly

all: ruleSymboleTable grammar.tab.c lex.yy.c commun/commun.c 
	$(CC) grammar.tab.c lex.yy.c commun/commun.c -o doc_html $(LIBS)
	mv doc_html ../bin

grammar.tab.c: commun/commun.h
	bison -d -v grammar.y

lex.yy.c: commun/commun.h
	flex grammar.l

commun/commun.c: commun/commun.h

ruleSymboleTable:
	make -C symboleTable/

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/doc_html symboleTable/testSymboleTable symboleStack/testSymboleStack symboleList/testSymboleList
