#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "symboleTable.h"

static int compareObject(void * a, void * b)
{
  TableObject to1 = (TableObject)a;
  TableObject to2 = (TableObject)b;
  return strcmp(to1->name, to2->name) == 0;
}

static char * copy(char * this)
{
  int size = strlen(this) + 1;
  char * res = malloc(sizeof(*res) * size);
  strcpy(res, this);
  return res;
}

TableObject createTableObject(char * name, char * class)
{
  TableObject 
  to = malloc(sizeof(*
    to));
  
  to->name = name;
  
  to->class = class;
  return 
  to;
}

void destroyTableObject(void * this)
{
  TableObject to = (TableObject)this;
  free(to->name);
  free(to->class);
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

char * searchSymboleTable(SymboleTable this, TableObject to, int indent)
{
  assert(indent >= 0 && "negative indent in searchSymboleTable");

  if (emptySymboleStack(this))
    return NULL;

  SymboleTable tmp = createSymboleTable();

  // if size == 1 and indent == 0 search in top list
  while (getSizeSymboleStack(this) - 1 > indent)
    pushSymboleStack(tmp, popSymboleStack(this));

  TableObject res = NULL;

  while (res == NULL && !emptySymboleStack(this)) {
    res = (TableObject)searchSymboleList(topSymboleStack(this), to);
    pushSymboleStack(tmp, popSymboleStack(this));
  }
  
  while (!emptySymboleStack(tmp))
    pushSymboleStack(this, popSymboleStack(tmp));
  destroySymboleTable(tmp);
  
  return res == NULL ? NULL : copy(res->class);
}