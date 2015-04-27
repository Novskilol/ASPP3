#ifndef STACK_H
#define STACK_H 

struct stack;
                                          
typedef struct stack * SymboleStack;
                                          
SymboleStack createSymboleStack();                 
                                          
void destroySymboleStack(SymboleStack this);           
                                          
void pushSymboleStack(SymboleStack this, void *object);
                                             
int emptySymboleStack(SymboleStack this);                 

void * topSymboleStack(SymboleStack this);

/* pop stack and return top object */
void * popSymboleStack(SymboleStack this);

int getSizeSymboleStack(SymboleStack this);

#endif