#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "symbolTable.h"

/**
 * @brief Given to createSymbolList to compare elements
 * @return true if a and b have the same name
*/
 static int compareObject(void * a, void * b)
 {
  TableObject to1 = (TableObject)a;
  TableObject to2 = (TableObject)b;
  return strcmp(to1->name, to2->name) == 0;
}

TableObject createTableObject(char * name, int class, char * declaration)
{
  TableObject to = malloc(sizeof(*to));
  to->name = copy(name);
  to->class = class;
  to->declaration = copy(declaration);
  return to;
}

void destroyTableObject(void * this)
{
  TableObject to = (TableObject)this;
  free(to->name);
  free(to->declaration);
  free(to);
}

SymbolTable createSymbolTable()
{
  SymbolTable stack = createSymbolStack();
  return stack;
}

void destroySymbolTable(SymbolStack this)
{
  while(!emptySymbolStack(this))
  {
    SymbolList s = popSymbolStack(this);
    destroySymbolList(s);
  }
  destroySymbolStack(this);
}

void addDeclarationTable(SymbolTable this, TableObject to, int indent)
{
  // getSizeSymbolStack(this)  == indent)
  //   pushSymbolStack(this, createSymbolList(compareObject, destroyTableObject));


  // else if (getSizeSymbolStack(this) - 1 > indent) {
  //   while (getSizeSymbolStack(this) - 1 > indent) {
  //     SymbolList s = popSymbolStack(this);
  //     destroySymbolList(s);
  //     printf("aaaaaaaaaaaaaaaaaaaaa");
  //   }
  // }
  // else {
  //   while (getSizeSymbolStack(this) - 1 < indent) {
  //     pushSymbolStack(this, createSymbolList(compareObject, destroyTableObject));
  //     printf("bbbbbbbbbbbbbbbbbbbbb");
  //   }
  // }

  SymbolList list = topSymbolStack(this);
  addSymbolList(list, to);
}

TableObject searchSymbolTable(SymbolTable this, char * name, int indent)
{
  assert(indent >= 0 && "negative indent in searchSymbolTable");

  if (emptySymbolStack(this))
    return NULL;

  SymbolTable tmp = createSymbolTable();

  // if size == 1 and indent == 0 search in top list
  while (getSizeSymbolStack(this) - 1 > indent)
    pushSymbolStack(tmp, popSymbolStack(this));

  TableObject res = NULL;
  TableObject to = createTableObject(name, 0, NULL);

  while (res == NULL && !emptySymbolStack(this)) {
    res = (TableObject)searchSymbolList(topSymbolStack(this), to);
    pushSymbolStack(tmp, popSymbolStack(this));
  }

  while (!emptySymbolStack(tmp))
    pushSymbolStack(this, popSymbolStack(tmp));
  destroySymbolTable(tmp);

  destroyTableObject(to);
  return res;
}

TableObject searchFunctionSymbolTable(SymbolTable this, char * name, int indent)
{
  assert(indent >= 0 && "negative indent in searchDeclarationSymbolTable");

  if (emptySymbolStack(this))
    return NULL;

  if (getSizeSymbolStack(this) - 1 != indent)
    return NULL;

  TableObject res = NULL;
  TableObject to = createTableObject(name, 0, NULL);

  res = (TableObject)searchSymbolList(topSymbolStack(this), to);

  destroyTableObject(to);
  return res;
}

/* Add empty List at stack top */
void pushSymbolTable(SymbolTable this) {
  pushSymbolStack(this, createSymbolList(compareObject, destroyTableObject));
}

/* Remove list from stack top */
void popSymbolTable(SymbolTable this) {
  SymbolList s = popSymbolStack(this);
  destroySymbolList(s);
}
