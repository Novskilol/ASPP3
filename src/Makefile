all: testDir
	bison -d -v grammar.y

	flex grammar.l

	gcc grammar.tab.c lex.yy.c -g -lfl -ly -o grammaireC
	mv grammaireC ../bin

testDir:
	if (test ! -d ../bin);then mkdir ../bin;fi
clean:
	/bin/rm -f *.output *.tab.h *.tab.c *.yy.c index.html ../bin/grammaireC
