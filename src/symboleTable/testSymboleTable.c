#include "symboleTable.h"

int indent = 0;

int main()
{
SymboleTable table = createSymboleTable();

// char * s = malloc(sizeof(char)* 2);
char * t = "x1";
char * t2 = "x2";
addSymboleTable(table, t, indent);
addSymboleTable(table, t, ++indent);
addSymboleTable(table, t2, indent);

// char * res = topSymboleStack(table);

destroySymboleTable(table);

}