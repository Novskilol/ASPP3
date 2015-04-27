#include <stdlib.h>
#include <stdio.h>

#include "symboleTable.h"

static void testSearch(SymboleTable table, char * name, int indent)
{
	TableObject	test = createTableObject(name, "");
	char * class = searchSymboleTable(table, test, indent);
	if (class != NULL)
		printf("var name %s got class %s with indent %d\n",
			test->name, class, indent);	
	else 
		printf("var name %s got no class with indent %d\n", 
			test->name, indent);
	destroyTableObject(test);
}


int main()
{
	SymboleTable table = createSymboleTable();

	TableObject tab [5];
	TableObject i0 = malloc(sizeof(*i0));
	TableObject i1 = malloc(sizeof(*i1));
	TableObject i2 = malloc(sizeof(*i2));
	TableObject i3 = malloc(sizeof(*i3));
	TableObject i4 = malloc(sizeof(*i4));
	i0->name = "y";
	i0->class = "y0";
	i1->name = "x";
	i1->class = "x1";
	i2->name = "x";
	i2->class = "x2";
	i3->name = "y";
	i3->class = "y3";
	i4->name = "x";
	i4->class = "x4";
	tab[0] = i0;
	tab[1] = i1;
	tab[2] = i2;
	tab[3] = i3;
	tab[4] = i4;
	
	int i;
	for(i = 0; i < 5; i++) {
		addDeclarationTable(table, tab[i], i);
	}

	testSearch(table, "x", 3);
	testSearch(table, "x", 5);
	testSearch(table, "y", 1);	
	testSearch(table, "y", 2);
	testSearch(table, "y", 3);
	testSearch(table, "y", 0);
	testSearch(table, "w", 4);


	destroySymboleTable(table);

} 