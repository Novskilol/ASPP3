#include "symboleTable.h"
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

typedef struct symboleList * SymboleList;
struct symboleList{
  struct list
};

struct stack_cell{
  struct stack_cell *next;
  SymboleList list;

};

struct symboleTable{
  struct stack_cell *top;
};

SymboleTable createSymboleTable()
{
  SymboleTable symboleTable=malloc(sizeof(*symboleTable));
  symboleTable->top=NULL;
  return symboleTable;
}
