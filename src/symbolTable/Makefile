INCDIR=../../include
CC = gcc -g -Wall -I$(INCDIR)

testSymbolTable: testSymbolTable.o symbolTable.o
	make -C ../symbolList
	make -C ../symbolStack
	make -C ../util
	$(CC) testSymbolTable.o symbolTable.o ../symbolStack/symbolStack.o ../symbolList/symbolList.o ../util/util.o -o testSymbolTable
	cp symbolTable.h ../../include
	cp symbolTable.o ../../lib
	cp testSymbolTable ../../bin
