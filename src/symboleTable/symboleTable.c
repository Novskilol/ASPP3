#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "symboleTable.h"

typdef list_cell_t {
	struct list_cell_t * next;
	char * name;
}* list_cell;


typedef struct symboleList_t {
 	list_cell first;
}* SymboleList;

typedef struct stack_cell_t {
  struct stack_cell_t * next;
  SymboleList list;
}* stack_cell;

struct symboleStack{
  stack_cell top; 
};

SymboleStack createSymboleTable()
{
  SymboleStack symboleTable = malloc(sizeof(*symboleTable));
  symboleTable->top = NULL;
  return symboleTable;
}

void deleteSymboleTable(SymboleStack symboleTable)
{
	assert(symboleTable != NULL);
	free(symboleTable);
}

