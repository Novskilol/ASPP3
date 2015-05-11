INCDIR=../../include
CC = gcc -g -Wall -I$(INCDIR)
all: necessary testFunctionParser

necessary:
	make -C ../util
	make -C ../symbolStack
	make -C ../symbolList
	make -C ../symbolTable

testFunctionParser: testFunctionParser.o functionParser.o
	$(CC) -I$(INCDIR) testFunctionParser.o functionParser.o ../util/util.o ../symbolTable/symbolTable.o ../symbolStack/symbolStack.o ../symbolList/symbolList.o -o testFunctionParser
	cp functionParser.h ../../include
	cp functionParser.o ../../lib
	cp testFunctionParser ../../bin
