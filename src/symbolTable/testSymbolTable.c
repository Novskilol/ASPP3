#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "symbolTable.h"

static int id = 1;

static void testSearch(SymbolTable table, char * name, int indent)
{
	TableObject to = searchSymbolTable(table, name, indent);

	if (to != NULL) {
		printf("\tvar name %s got class %d with indent %d\n", 
			name, to->class, indent);	
	}
	else 
		printf("\tvar name %s got no class with indent %d\n", 
			name, indent);
}

static void testAddDeclaration(SymbolTable table, TableObject to, int indent)
{
	addDeclarationTable(table, to, indent);
	printf("added var name %s with class %d declared in indent %d\n", 
		to->name, to->class, indent);
}

int main()
{
	SymbolTable table = createSymbolTable();

	TableObject tab [5];
	TableObject to0 = createTableObject("y", id++, NULL);
	TableObject to1 = createTableObject("x", id++, NULL);
	TableObject to2 = createTableObject("x", id++, NULL);
	TableObject to3 = createTableObject("y", id++, NULL);
	TableObject to4 = createTableObject("x", id++, NULL);
	
	tab[0] = to0;
	tab[1] = to1;
	tab[2] = to2;
	tab[3] = to3;
	tab[4] = to4;

	testSearch(table, "w", 0);

	int i;
	for(i = 0; i < 5; i++) {
		testAddDeclaration(table, tab[i], i);
	}

	testSearch(table, "w", 0);
	
	testSearch(table, "x", 0);
	testSearch(table, "x", 1);
	testSearch(table, "x", 2);
	testSearch(table, "x", 3);
	testSearch(table, "x", 4);
	testSearch(table, "x", 5);

	testSearch(table, "y", 0);	
	testSearch(table, "y", 1);
	testSearch(table, "y", 2);
	testSearch(table, "y", 3);
	testSearch(table, "y", 4);
	testSearch(table, "y", 5);

	TableObject to5 = createTableObject("w", id++, NULL);
	testAddDeclaration(table, to5, 3);

	testSearch(table, "w", 0);
	testSearch(table, "w", 1);
	testSearch(table, "w", 2);
	testSearch(table, "w", 3);
	testSearch(table, "w", 4);
	
	testSearch(table, "x", 0);
	testSearch(table, "x", 1);
	testSearch(table, "x", 2);
	testSearch(table, "x", 3);
	testSearch(table, "x", 4);
	testSearch(table, "x", 5);
	
	testSearch(table, "y", 0);	
	testSearch(table, "y", 1);
	testSearch(table, "y", 2);
	testSearch(table, "y", 3);
	testSearch(table, "y", 4);

	destroySymbolTable(table);

	return 0;
} 
