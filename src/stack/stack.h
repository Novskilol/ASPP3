#ifndef STACK_H
#define STACK_H 

struct stack;
                                          
typedef struct stack * Stack;
                                          
Stack stack_create(void);                 
                                          
void stack_destroy(Stack this);           
                                          
void stack_push(Stack this, void *object);
                                             
int stack_empty(Stack this);                 

void * stack_top(Stack this);

/* pop stack and return top object */
void * stack_pop(Stack this);

#endif