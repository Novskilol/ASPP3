INCDIR="../../include"
CC = gcc -g -Wall -I$(INCDIR)
testSymboleTable: testSymboleTable.o symboleTable.o
	make -C ../symboleList
	make -C ../symboleStack
	gcc -Wall -g testSymboleTable.o symboleTable.o ../symboleStack/symboleStack.o ../symboleList/symboleList.o -o testSymboleTable
	cp symboleTable.h ../../include
	cp symboleTable.o ../../lib
	cp testSymboleTable ../../bin