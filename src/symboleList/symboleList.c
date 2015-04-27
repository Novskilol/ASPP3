#include "symboleList.h"
#include <stdlib.h>
#include <assert.h>
struct cell_symbole_list{
  struct cell_symbole_list *next;
  void *value;
};
struct symboleList{
  struct cell_symbole_list *last;
  DestroyFunction destroyCellValueFunction;
  CompareFunction compareCellValueFunction;

};
void destroySymboleList(SymboleList this)
{
  int i;
  struct cell_symbole_list *curseur;

  for (curseur=this->last ; curseur != NULL ;)
    {
      struct cell_symbole_list *toBeDeleted=curseur;
      curseur=curseur->next;
      this->destroyCellValueFunction(toBeDeleted->value);
      free(toBeDeleted);
    }

  free(this);

}
void* searchSymboleList(SymboleList this, void *value)
{
  struct cell_symbole_list *curseur=this->last;



  for (;curseur!=NULL && !(this->compareCellValueFunction(curseur->value,value)) ;curseur=curseur->next);

  
  assert(curseur != NULL);
  return curseur->value;

}

void addSymboleList(SymboleList this,void *value)
{
  struct cell_symbole_list *newLast = malloc(sizeof(*newLast));
  newLast->value=value;
  newLast->next=this->last;
  this->last=newLast;
  

}

int emptySymboleList(SymboleList this)
{
  return  this->last == NULL;

}

SymboleList createSymboleList(CompareFunction c,DestroyFunction f){
  SymboleList s = malloc(sizeof(*s));
  s->last = NULL;
  s->destroyCellValueFunction = f;
  s->compareCellValueFunction = c;
  return s;

}
