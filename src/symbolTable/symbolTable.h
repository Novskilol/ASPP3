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

/**
 * Create new object to be stored in ours linked lists
 * @param  name        The identifier name
 * @param  class       The unique identifier class, used for javascript
 * @param  declaration not used
 * @return             The new object created
 */
TableObject createTableObject(char * name, int class, char * declaration);

/**
 * @detail Fonction called when we want to destroy an object stored in ours linked lists, given as argument to the linked list function creation
 * @param this Our object to be destroyed
 */
void destroyTableObject(void * this);

/**
 * @detail Create new Symbol Table, it's just a stack of linked list, from each list from the stack corresponds an identation level
 * @return The new Symbol Table
 */
SymbolTable createSymbolTable();

/**
 * @detail Destroy and free every object from our Symbol Table
 * @param this The Symbol Table to be destroyed
 */
void destroySymbolTable(SymbolTable this);

/**
 * @detail Add new object (identifier declaration) in our Symbol Table
 * @param this   Our Symbol Table
 * @param to     The object to be added
 * @param indent Our indentation level
 */
void addDeclarationTable(SymbolTable this, TableObject to, int indent);

/**
 * @detail Search for variable declaration, called whenever we encounter an identifier undeclared
 * @param  this   Our Symbol Table
 * @param  name   Our indentifier name
 * @param  indent Our identation level
 * @return        The stored object
 */
TableObject searchSymbolTable(SymbolTable this, char * name, int indent);

/**
 * @detail Search for already declared function, called when we encounter a function definition
 * @param  this   Our Symbol Table
 * @param  name   Function name
 * @param  indent Our identation Level
 * @return        The stored object
 */
TableObject searchFunctionSymbolTable(SymbolTable this, char * name, int indent);

/**
 * @brief Add empty List in our Symbol Table
 * @param this Our Symbol Table
 */
void pushSymbolTable(SymbolTable this);

/**
 * @brief Remove top List from our Symbol Table
 * @param this Our Symbol Table
 */
void popSymbolTable(SymbolTable this);

#endif
