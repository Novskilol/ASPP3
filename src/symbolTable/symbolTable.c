#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "symbolTable.h"

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

SymboleTable createSymboleTable()
{
  SymboleTable stack = createSymboleStack();
  return stack;
}

void destroySymboleTable(SymboleStack this)
{
  while(!emptySymboleStack(this))
  {
    SymboleList s = popSymboleStack(this);
    destroySymboleList(s);
  }
  destroySymboleStack(this);
}

void addDeclarationTable(SymboleTable this, TableObject to, int indent)
{
  if (getSizeSymboleStack(this) == indent)
    pushSymboleStack(this, createSymboleList(compareObject, destroyTableObject));

  else if (getSizeSymboleStack(this) - 1 > indent) {
    while (getSizeSymboleStack(this) - 1 > indent) {
      SymboleList s = popSymboleStack(this);
      destroySymboleList(s);
    }
  }
  else {
    while (getSizeSymboleStack(this) - 1 < indent) {
      pushSymboleStack(this, createSymboleList(compareObject, destroyTableObject));
    }
  }

  SymboleList list = topSymboleStack(this);
  addSymboleList(list, to);
}

TableObject searchSymboleTable(SymboleTable this, char * name, int indent)
{
  assert(indent >= 0 && "negative indent in searchSymboleTable");

  if (emptySymboleStack(this))
    return NULL;

  SymboleTable tmp = createSymboleTable();

  // if size == 1 and indent == 0 search in top list
  while (getSizeSymboleStack(this) - 1 > indent)
    pushSymboleStack(tmp, popSymboleStack(this));

  TableObject res = NULL;
  TableObject to = createTableObject(name, 0, NULL);

  while (res == NULL && !emptySymboleStack(this)) {
    res = (TableObject)searchSymboleList(topSymboleStack(this), to);
    pushSymboleStack(tmp, popSymboleStack(this));
  }
  
  while (!emptySymboleStack(tmp))
    pushSymboleStack(this, popSymboleStack(tmp));
  destroySymboleTable(tmp);
  
  destroyTableObject(to);
  return res;
}

TableObject searchDeclarationFunctionSymboleTable(SymboleTable this, char * name, int indent) 
{
  assert(indent >= 0 && "negative indent in searchDeclarationSymboleTable");

  if (emptySymboleStack(this))
    return NULL;

  if (getSizeSymboleStack(this) - 1 != indent)
    return NULL;

  TableObject res = NULL;
  TableObject to = createTableObject(name, 0, NULL);

  res = (TableObject)searchSymboleList(topSymboleStack(this), to);

  destroyTableObject(to);
  return res;
}

/* Add empty List at stack top */
void pushSymboleTable(SymboleTable this) {
  pushSymboleStack(this, createSymboleList(compareObject, destroyTableObject));
}

/* Remove list from stack top */
void popSymboleTable(SymboleTable this) {
  SymboleList s = popSymboleStack(this);
  destroySymboleList(s);
}
