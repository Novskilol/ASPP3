INCDIR="../../include"
CC = gcc -g -Wall -I$(INCDIR)

all:testSymbolStack
	cp symbolStack.h ../../include
	cp symbolStack.o ../../lib
	cp testSymbolStack ../../bin
	
testSymbolStack:testSymbolStack.o symbolStack.o