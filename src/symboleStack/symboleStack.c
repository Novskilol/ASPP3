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


Stack createSymboleStack()                                      
{                                                         
	Stack this = malloc(sizeof(*this)); 
	this->top = NULL;                                          
	return this;                                               
}                                                         

void destroySymboleStack(Stack this)                               
{                                                         
	assert(this && "invalid Stack in destroySymboleStack");            
	assert(!this->top && "invalid Stack top in destroySymboleStack");  
	free(this);                                              
}                                                         

void pushSymboleStack(Stack this, void *object)                    
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

void * topSymboleStack(Stack this)                                 
{                                                         
	assert(this && "invalid Stack in topSymboleStack");                
	assert(this->top && "invalid Stack top in topSymboleStack");       
	return this->top->object;
}

void * popSymboleStack(Stack this)
{
	assert(this && "invalid Stack in popSymboleStack");
	assert(this->top && "invalid Stack top in popSymboleStack");
	Cell prev = this->top->prev;
	void * old_object = this->top->object;
	free(this->top);
	this->top = prev;
	return old_object;
}
