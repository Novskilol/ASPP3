#include <stdlib.h>
#include <assert.h>

#include "symbolStack.h"

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
	int size; 
};                                                        


SymboleStack createSymboleStack()                                      
{                                                         
	SymboleStack this = malloc(sizeof(*this)); 
	this->top = NULL;      
	this->size = 0;                                    
	return this;                                               
}                                                         

void destroySymboleStack(SymboleStack this)                               
{                                 
	free(this);                                              
}                                                     

void pushSymboleStack(SymboleStack this, void *object)                    
{        
	Cell cell = malloc(sizeof(*cell));                    
	cell->object = object;                                
	cell->prev = this->top;                                 
	this->top = cell;          
	++(this->size);                             
}                                                         

int emptySymboleStack(SymboleStack this)                                  
{                                                         
	assert(this && "invalid SymboleStack in emptySymboleStack");                                            
	return !this->top;                                      
}                                                         

void * topSymboleStack(SymboleStack this)                                 
{                                                         
	assert(this && "invalid SymboleStack in topSymboleStack");                
	assert(this->top && "invalid SymboleStack top in topSymboleStack");       
	return this->top->object;
}

void * popSymboleStack(SymboleStack this)
{
	assert(this && "invalid SymboleStack in popSymboleStack");
	assert(this->top && "invalid SymboleStack top in popSymboleStack");
	Cell prev = this->top->prev;
	void  * old_object = this->top->object;
	free(this->top);
	this->top = prev;
	--(this->size);
	return old_object;
}

int getSizeSymboleStack(SymboleStack this) 
{
	return this->size;
}
