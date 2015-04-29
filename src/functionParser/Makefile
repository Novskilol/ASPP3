INCDIR="../../include"
CC = gcc -g -Wall -I$(INCDIR)
all:testFunctionParser 
	cp functionParser.h ../../include
	cp functionParser.o ../../lib
	cp testFunctionParser ../../bin
testFunctionParser:testFunctionParser.o functionParser.o

