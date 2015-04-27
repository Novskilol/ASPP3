#include "symboleQueue.h"

struct cell_symbole_queue{
  struct cell_symbole_queue *next;
  void *value;
};
struct symboleQueue{
  struct cell_symbole_queue *last;
  DestroyFunction destroyCellValueFunction;
  

};
void destroySymboleQueue(SymboleQueue this)
{
  int i;
  struct cell_symbole_queue *curseur=this->last;

  for ( i = 0; i < value ; ++i,)
    {
      struct cell_symbole_queue *toBeDeleted=curseur;
      curseur=curseur->next;
      this->destroyFunction(curseur->value);
      free(curseur);
    }

  

}
void* getSymboleQueue(SymboleQueue this, int value)
{
  int i;
  struct cell_symbole_queue *curseur=this->last;

  for ( i = 0; i < value ; ++i,curseur=curseur->next);

  return curseur->value;

}

void addSymboleQueue(SymboleQueue this,void *value)
{
  struct cell_symbole_queue *newLast = malloc(sizeof(*newLast));
  newLast->value=value;
  newLast->next=this->last;
  this->last=newLast;
  

}

int emptySymboleQueue(SymboleQueue this)
{
  return  this->last == NULL;

}

SymboleQueue createSymboleQueue(DestroyFunction f){
  SymboleQueue s = malloc(sizeof(*s));
  s->last = NULL;
  s->destroyFunction = f;
  return s;

}
