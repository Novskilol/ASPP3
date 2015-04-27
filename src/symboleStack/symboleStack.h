#ifndef STACK_H
#define STACK_H 

struct stack;
                                          
typedef struct stack * Stack;
                                          
Stack createSymboleStack(void);                 
                                          
void destroySymboleStack(Stack this);           
                                          
void pushSymboleStack(Stack this, void *object);
                                             
int stack_empty(Stack this);                 

void * topSymboleStack(Stack this);

/* pop stack and return top object */
void * popSymboleStack(Stack this);

#endif