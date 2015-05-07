CC = gcc -g -Wall
LIBS = -lfl -ly -lm
INCDIR=../include
LDIR=../lib

all: testDir  compilation

latex:
	flex --outfile=latex.yy.c latex.l
	bison -d -v latex.y
	$(CC) latex.yy.c -I$(INCDIR) $(LDIR)/symbolStack.o -lfl -lm -o rapport_html
	mv rapport_html ../bin



compilation: commun/commun.o util/util.o symbolTable/symbolTable.o symbolStack/symbolStack.o symbolList/symbolList.o functionParser/functionParser.o grammar.tab.o lex.yy.o
	$(CC) $^ $(LIBS) -o doc_html
	mv doc_html ../bin


testDir:
	if (test ! -d ../lib) ;then  mkdir ../lib;fi
	if (test ! -d ../include);then mkdir ../include;fi
	if (test ! -d ../bin);then mkdir ../bin;fi
	if (test ! -d output);then mkdir output;fi

grammar.tab.o: commun/commun.h util/util.h
	bison -d -v grammar.y
	cp grammar.tab.h $(INCDIR)
	$(CC) -c -I$(INCDIR) grammar.tab.c -o grammar.tab.o

lex.yy.o: commun/commun.h
	flex grammar.l
	$(CC) -c -I$(INCDIR) lex.yy.c -o lex.yy.o

commun/commun.o: commun/commun.h commun/commun.c
	make -C commun/

util/util.o: util/util.h util/util.c
	make -C util/

functionParser/functionParser.o:
	make -C functionParser/

symbolList/symbolList.o:
	make -C symbolList/

symbolStack/symbolStack.o:
	make -C symbolStack

symbolTable/symbolTable.o: symbolTable/symbolTable.h symbolStack/symbolStack.h symbolList/symbolList.h util/util.h
	make -C symbolTable

clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c output/* ../bin/* ../lib/* symbolTable/testSymbolTable symbolStack/testSymbolStack symbolList/testSymbolList functionParser/testFunctionParser */*.o *.o ../include/*.h
