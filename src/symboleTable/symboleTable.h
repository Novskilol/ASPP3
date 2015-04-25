#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H
typedef struct symboleTable * SymboleTable;
void addSymbole(char *symbole,int indentationLvl,int id);
int getIdDeclaration(char *symbole,int indentationLvl);
SymboleTable createSymboleTable();

#endif
