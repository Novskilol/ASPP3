#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "symboleTable.h"



static int compareObject(tableObject a, tableObject b)
{
  return strcmp(a, b) == 0;
}

static void destroyObject(tableObject this)
{
  // free(this);
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

void addSymboleTable(SymboleTable this, tableObject var, int indent)
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

