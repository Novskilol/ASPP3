#ifndef SYMBOLE_LIST_H
#define SYMBOLE_LIST_H

typedef struct symbolList *SymbolList;
typedef void (*DestroyFunction) (void *);
typedef int (*CompareFunction) (void *,void *);
/**
 * @brief Allocate and init a new SymbolList 
 * @return a new SymbolList
 * @param c , a CompareFunction which is used by searchSymbolList
 * @param f , a DestroyFunction which is used by destroySymbolList on each element
 * @ref{destroySymbolList} 
 */
SymbolList createSymbolList(CompareFunction c,DestroyFunction f);

/**
 * @brief Destroy a SymbolList and use DestroyFunction on each object
 * @param this , the SymbolList to be destroyed.
 * @label{destroySymbolList}
 */
void destroySymbolList(SymbolList this);

int emptySymbolList(SymbolList this);

void addSymbolList(SymbolList this,void* value);

/**
 * @brief search a value compared with CompareFunction to all the list
 * @return return NULL if not found , otherwise return the Symbol found
 */
void* searchSymbolList(SymbolList this, void* value);


void* getLastSymbolList(SymbolList this);

#endif
