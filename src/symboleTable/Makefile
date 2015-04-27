test_symbole_table: test_symbole_table.o symboleTable.o
	make -C ../symboleList
	make -C ../symboleStack
	gcc -g test_symbole_table.o symboleTable.o ../symboleStack/symboleStack.o ../symboleList/symboleList.o -o test_symbole_table
