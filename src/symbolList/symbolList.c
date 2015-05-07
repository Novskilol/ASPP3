#include <stdlib.h>
#include <assert.h>

#include "symbolList.h"

struct cell_symbol_list{
  struct cell_symbol_list *next;
  void *value;
};
struct symbolList{
  struct cell_symbol_list *last;
  DestroyFunction destroyCellValueFunction;
  CompareFunction compareCellValueFunction;

};

void destroySymbolList(SymbolList this)
{
  struct cell_symbol_list *curseur;

  for (curseur=this->last ; curseur != NULL ;)
  {
    struct cell_symbol_list *toBeDeleted=curseur;
    curseur=curseur->next;
    this->destroyCellValueFunction(toBeDeleted->value);
    free(toBeDeleted);
  }

  free(this);

}
void* getLastSymbolList(SymbolList this)
{
  return this->last->value;
}
void* searchSymbolList(SymbolList this, void *value)
{
  struct cell_symbol_list *curseur=this->last;



  for (;curseur!=NULL && !(this->compareCellValueFunction(curseur->value,value)) ;curseur=curseur->next);

    if (curseur == NULL)
      return NULL;    
    return curseur->value;

  }

  void addSymbolList(SymbolList this,void *value)
  {
    struct cell_symbol_list *newLast = malloc(sizeof(*newLast));
    newLast->value=value;
    newLast->next=this->last;
    this->last=newLast;
    

  }

  int emptySymbolList(SymbolList this)
  {
    return  this->last == NULL;

  }

  SymbolList createSymbolList(CompareFunction c,DestroyFunction f){
    SymbolList s = malloc(sizeof(*s));
    s->last = NULL;
    s->destroyCellValueFunction = f;
    s->compareCellValueFunction = c;
    return s;

  }
