all:
	bison -d -v grammar.y

	flex grammar.l

	gcc grammar.tab.c lex.yy.c -lfl -ly -o test
