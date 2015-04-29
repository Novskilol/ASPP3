#ifndef SYMBOLE_LIST_H
#define SYMBOLE_LIST_H

typedef struct symbolList *SymbolList;
typedef void (*DestroyFunction) (void *);
typedef int (*CompareFunction) (void *,void *);

SymbolList createSymbolList(CompareFunction c,DestroyFunction f);

void destroySymbolList(SymbolList this);

int emptySymbolList(SymbolList this);

void addSymbolList(SymbolList this,void* value);

void* searchSymbolList(SymbolList this, void* value);


#endif
