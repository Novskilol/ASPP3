#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

#include "../symbolStack/symbolStack.h"
#include "../symbolList/symbolList.h"
#include "../util/util.h"

typedef SymboleStack SymboleTable;

typedef struct {
	char * name;
	char * class;
	char * declaration;
}* TableObject;

TableObject createTableObject(char * name, int class, char * declaration); // a enlever du .h

void destroyTableObject(void * this); // idem

SymboleTable createSymboleTable();

void destroySymboleTable(SymboleTable this);

void addDeclarationTable(SymboleTable this, TableObject to, int indent);

int getIdDeclaration(void * this);

TableObject searchSymboleTable(SymboleTable this, char * name, int indent);

TableObject searchDeclarationFunctionSymboleTable(SymboleTable this, char * name, int indent);

void pushSymboleTable(SymboleTable this);

void popSymboleTable(SymboleTable this);

#endif
