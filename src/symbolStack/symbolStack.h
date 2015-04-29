#ifndef STACK_H
#define STACK_H 

struct stack;
                                          
typedef struct stack * SymbolStack;
                                          
SymbolStack createSymbolStack();                 
                                          
void destroySymbolStack(SymbolStack this);           
                                          
void pushSymbolStack(SymbolStack this, void *object);
                                             
int emptySymbolStack(SymbolStack this);                 

void * topSymbolStack(SymbolStack this);

/* pop stack and return top object */
void * popSymbolStack(SymbolStack this);

int getSizeSymbolStack(SymbolStack this);

#endif