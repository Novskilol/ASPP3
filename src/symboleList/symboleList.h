#ifndef SYMBOLE_QUEUE_H
#define SYMBOLE_QUEUE_H

typedef struct symboleQueue *SymboleQueue;
typedef void (*DestroyFunction) (void *);

SymboleQueue createSymboleQueue();

void destroySymboleQueue(SymboleQueue this);

int emptySymboleQueue(SymboleQueue this);

void addSymboleQueue(SymboleQueue this,void* value,int sizeofValue);

void* getSymboleQueue(SymboleQueue this,int value);

#endif
