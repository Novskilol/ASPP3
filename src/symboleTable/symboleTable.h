#ifndef SYMBOLE_TABLE_H
#define SYMBOLE_TABLE_H

#include "../symboleStack/symboleStack.h"
#include "../symboleList/symboleList.h"

typedef SymboleStack SymboleTable;

typedef struct {
	char * name;
	char * class;
}* TableObject;

TableObject createTableObject(char * name, char * class); // a enlever du .h

void destroyTableObject(void * this); // idem

SymboleTable createSymboleTable();

void destroySymboleTable(SymboleTable this);

void addDeclarationTable(SymboleTable this, TableObject to, int indent);

int getIdDeclaration(void * this);

char * searchSymboleTable(SymboleTable this, char * name, int indent);

#endif
