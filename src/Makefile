CC = gcc -g -Wall
LIBS = -lfl -ly -lm
INCDIR=../include
all: testDir compilation 

latex:
	flex latex.l
	$(CC) lex.yy.c -lfl -lm -o lat_exe

compilation: commun/commun.o symboleTable/symboleTable.o symboleStack/symboleStack.o symboleList/symboleList.o functionParser/functionParser.o grammar.tab.o lex.yy.o 
	$(CC) $^ $(LIBS) -o doc_html 
	mv doc_html ../bin

testDir:	
	if (test ! -d ../lib) ;then  mkdir ../lib;fi
	if (test ! -d ../include);then mkdir ../include;fi
	if (test ! -d ../bin);then mkdir ../bin;fi

grammar.tab.o: commun/commun.h
	bison -d -v grammar.y
	cp grammar.tab.h $(INCDIR)
	gcc -c -I$(INCDIR) grammar.tab.c -o grammar.tab.o

lex.yy.o: commun/commun.h
	flex grammar.l
	gcc -c -I$(INCDIR) lex.yy.c -o lex.yy.o

commun/commun.o: commun/commun.h commun/commun.c
	make -C commun/
functionParser/functionParser.o : 
	make -C functionParser/
symboleList/symboleList.o: 
	make -C symboleList/
symboleStack/symboleStack.o: 
	make -C symboleStack

symboleTable/symboleTable.o: symboleTable/symboleTable.h symboleStack/symboleStack.h symboleList/symboleList.h
	make -C symboleTable

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/doc_html symboleTable/testSymboleTable symboleStack/testSymboleStack symboleList/testSymboleList */*.o *.o
