#include <stdlib.h>
#include <stdio.h>

#include "symboleTable.h"

int indent = 0;

int main()
{
SymboleTable table = createSymboleTable();

TableObject tab [5];
int i;
for(i = 0; i < 5; i++) {
	tab[i] = malloc(sizeof(**tab));
	tab[i]->class = (char*)'0'+i;
	tab[i]->name = (char*)'0'+i;	
	addDeclarationTable(table, tab[i], i);
}

char * class = searchSymboleTable(table, (char*)'0'+3, 3);
printf("%s\n", class);

destroySymboleTable(table);

} 