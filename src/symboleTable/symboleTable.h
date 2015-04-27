#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

typedef struct SymboleStack * SymboleStack;

void addSymbole(char *symbole, int indentationLvl, int id);

int getIdDeclaration(char *symbole, int indentationLvl);

SymboleStack createSymboleTable();

void deleteSymboleTable();

#endif
