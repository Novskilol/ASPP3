#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

#include "../symbolStack/symbolStack.h"
#include "../symbolList/symbolList.h"
#include "../util/util.h"

typedef SymbolStack SymbolTable;

typedef struct {
	char * name;
	int class;
	char * declaration;
}* TableObject;

TableObject createTableObject(char * name, int class, char * declaration); // a enlever du .h

void destroyTableObject(void * this); // idem

SymbolTable createSymbolTable();

void destroySymbolTable(SymbolTable this);

void addDeclarationTable(SymbolTable this, TableObject to, int indent);

int getIdDeclaration(void * this);

TableObject searchSymbolTable(SymbolTable this, char * name, int indent);

TableObject searchDeclarationFunctionSymbolTable(SymbolTable this, char * name, int indent);

void pushSymbolTable(SymbolTable this);

void popSymbolTable(SymbolTable this);

#endif
