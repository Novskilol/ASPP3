#ifndef SYMBOLE_LIST_H
#define SYMBOLE_LIST_H

typedef struct symbolList *SymboleList;
typedef void (*DestroyFunction) (void *);
typedef int (*CompareFunction) (void *,void *);

SymboleList createSymboleList(CompareFunction c,DestroyFunction f);

void destroySymboleList(SymboleList this);

int emptySymboleList(SymboleList this);

void addSymboleList(SymboleList this,void* value);

void* searchSymboleList(SymboleList this, void* value);


#endif
