#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "symboleTable.h"



static int compareObject(void * a, void * b)
{
  TableObject to1 = (TableObject)a;
  TableObject to2 = (TableObject)b;
  return strcmp(to1->name, to2->name) == 0;
}

static void destroyObject(void * this)
{
  TableObject t=(TableObject)this;
  free(t->name);
  free(t->class);
  free(t);
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
    SymboleList s=popSymboleStack(this);
    destroySymboleList(s);
  }
  destroySymboleStack(this);
}

void addDeclarationTable(SymboleTable this, TableObject var, int indent)
{
  while(getSizeSymboleStack(this) > indent)
  {
    SymboleList s=popSymboleStack(this);
    destroySymboleList(s);
  }
  while(getSizeSymboleStack(this) < indent) {
    pushSymboleStack(this, createSymboleList(compareObject, destroyObject));
  }
  if (getSizeSymboleStack(this) == 0 && indent == 0)
    pushSymboleStack(this, createSymboleList(compareObject, destroyObject));

  SymboleList list = topSymboleStack(this);
  addSymboleList(list, var);
}

char * searchSymboleTable(SymboleTable this, char * name, int indent)
{
  assert(indent >= 0);
  SymboleTable tmp = createSymboleTable();
  
  while(getSizeSymboleStack(this) > indent)
    pushSymboleStack(tmp, popSymboleStack(this));

  while(getSizeSymboleStack(this) < indent)
    return NULL;

  TableObject to = (TableObject)searchSymboleList(topSymboleStack(this), name);
  while (to == NULL && !emptySymboleStack(this)) {
    pushSymboleStack(tmp, popSymboleStack(this));
    to = (TableObject)searchSymboleList(topSymboleStack(this), name);
  }
  if (emptySymboleStack(this))
    return NULL;

  while(!emptySymboleStack(tmp))
    pushSymboleStack(this, popSymboleStack(tmp));
  destroySymboleTable(tmp);

  return to->class;
}