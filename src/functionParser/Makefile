INCDIR="../../include"
CC = gcc -g -Wall -I$(INCDIR)

testFunctionParser: testFunctionParser.o functionParser.o
	make -C ../util
	$(CC) testFunctionParser.o functionParser.o ../util/util.o -o testFunctionParser
	cp functionParser.h ../../include
	cp functionParser.o ../../lib
	cp testFunctionParser ../../bin
