#include <stdlib.h>
#include <assert.h>

#include "stack.h"

struct cell;                                                    
typedef struct cell * Cell;                                     

struct cell                                                     
{                                                               
	Cell prev;                                                  
	void * object;                                              
};                                                              

struct stack                                         
{                                                         
	Cell top;                                             
};                                                        


Stack stack_create()                                      
{                                                         
	Stack this = malloc(sizeof(*this)); 
	this->top = NULL;                                          
	return this;                                               
}                                                         

void stack_destroy(Stack this)                               
{                                                         
	assert(this && "invalid Stack in stack_destroy");            
	assert(!this->top && "invalid Stack top in stack_destroy");  
	free(this);                                              
}                                                         

void stack_push(Stack this, void *object)                    
{        
	Cell cell = malloc(sizeof(*cell));                    
	cell->object = object;                                
	cell->prev = this->top;                                 
	this->top = cell;                                       
}                                                         

int stack_empty(Stack this)                                  
{                                                         
	assert(this);                                            
	return !this->top;                                      
}                                                         

void * stack_top(Stack this)                                 
{                                                         
	assert(this && "invalid Stack in stack_top");                
	assert(this->top && "invalid Stack top in stack_top");       
	return this->top->object;
}

void * stack_pop(Stack this)
{
	assert(this && "invalid Stack in stack_pop");
	assert(this->top && "invalid Stack top in stack_pop");
	Cell prev = this->top->prev;
	void * old_object = this->top->object;
	free(this->top);
	this->top = prev;
	return old_object;
}
