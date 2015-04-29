INCDIR="../../include"
CC = gcc -g -Wall -I$(INCDIR)

all:testSymbolList 
	cp symbolList.h ../../include
	cp symbolList.o ../../lib
	cp testSymbolList ../../bin
	
testSymbolList:testSymbolList.o symbolList.o