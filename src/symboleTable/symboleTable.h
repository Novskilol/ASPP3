#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

// typedef void * table_object;
// typedef void (*table_del_func(table_object);
// typedef void (*table_comp_func(table_object, table_object);

typedef Stack SymboleTable;
stack_pop
SymboleTable createSymboleTable();

void deleteSymboleTable(SymboleTable this);

void addSymbole(char *symbole, int indentationLvl, int id);

int getIdDeclaration(char *symbole, int indentationLvl);



#endif
