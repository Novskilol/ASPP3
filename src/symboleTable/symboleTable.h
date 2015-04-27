#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

#include "../symboleStack/symboleStack.h"
#include "../symboleList/symboleList.h"
// typedef void * void *;
// typedef void (*table_del_func(void *);
// typedef void (*table_comp_func(void *, void *);

typedef SymboleStack SymboleTable;

typedef void * tableObject;

SymboleTable createSymboleTable();

void destroySymboleTable(SymboleTable this);

void addSymbole(void * this, int indent);

int getIdDeclaration(void * this);

#endif