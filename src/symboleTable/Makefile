testSymboleTable: testSymboleTable.o symboleTable.o
	make -C ../symboleList
	make -C ../symboleStack
	gcc -g testSymboleTable.o symboleTable.o ../symboleStack/symboleStack.o ../symboleList/symboleList.o -o testSymboleTable
