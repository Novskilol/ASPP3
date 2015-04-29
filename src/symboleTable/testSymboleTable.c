#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "symboleTable.h"

static void testSearch(SymboleTable table, char * name, int indent)
{
	TableObject to = searchSymboleTable(table, name, indent);

	if (to != NULL) {
		printf("var name %s got class %s with indent %d\n", 
			name, to->class, indent);	
	}
	else 
		printf("var name %s got no class with indent %d\n", 
			name, indent);
}

int main()
{
	SymboleTable table = createSymboleTable();

	TableObject tab [5];
	TableObject to0 = createTableObject("y", "0", NULL);
	TableObject to1 = createTableObject("x", "1", NULL);
	TableObject to2 = createTableObject("x", "2", NULL);
	TableObject to3 = createTableObject("y", "3", NULL);
	TableObject to4 = createTableObject("x", "4", NULL);
	

	tab[0] = to0;
	tab[1] = to1;
	tab[2] = to2;
	tab[3] = to3;
	tab[4] = to4;

	testSearch(table, "w", 0);

	int i;
	for(i = 0; i < 5; i++) {
		addDeclarationTable(table, tab[i], i);
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

	TableObject to5 = createTableObject("w", "w3", NULL);
	addDeclarationTable(table, to5, 3);

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

	destroySymboleTable(table);

	return 0;
} 
