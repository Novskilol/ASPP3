#ifndef STACK_H
#define STACK_H

struct stack;

typedef struct stack * SymbolStack;

/**
 * @detail Create empty stack
 * @return The new stack
 */
SymbolStack createSymbolStack();

/**
 * @detail Destroy stack, the stack should contain no element
 * @param this The stack te be freed
 */
void destroySymbolStack(SymbolStack this);

/**
 * @detail Add object to stack
 * @param this   Our stack
 * @param object The object to be added
 */
void pushSymbolStack(SymbolStack this, void *object);

/**
 * @param  this Our stack
 * @return      True if the stack is empty
 */
int emptySymbolStack(SymbolStack this);

/**
 * @param  this Our stack
 * @return      The stack top element
 */
void * topSymbolStack(SymbolStack this);

/**
 * @detail Pop stack and return top object without destroying it
 * @param  this Our stack
 * @return      The top object
 */
void * popSymbolStack(SymbolStack this);

/**
 * @param  this Our stack
 * @return      The number of element stored in the stack
 */
int getSizeSymbolStack(SymbolStack this);

#endif
