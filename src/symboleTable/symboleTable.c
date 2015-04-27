#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "symboleTable.h"
#include "../symboleStack/symboleStack.h"
#include "../symboleList/symboleList.h"

typedef char * table_object;

static int compareObject(table_object a, table_object b)
{
  return strcmp(a, b) == 0;
}

static void destroyObject(table_object this)
{
  free(this);
}

SymboleTable createSymboleTable()
{
  SymboleTable stack = createSymboleStack();
  return stack;
}

void destroySymboleTable(SymboleStack this)
{
	destroySymboleStack(this);
}

