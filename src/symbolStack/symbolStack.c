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


SymbolStack createSymbolStack()                                      
{                                                         
	SymbolStack this = malloc(sizeof(*this)); 
	this->top = NULL;      
	this->size = 0;                                    
	return this;                                               
}                                                         

void destroySymbolStack(SymbolStack this)                               
{                                 
	free(this);                                              
}                                                     

void pushSymbolStack(SymbolStack this, void *object)                    
{        
	Cell cell = malloc(sizeof(*cell));                    
	cell->object = object;                                
	cell->prev = this->top;                                 
	this->top = cell;          
	++(this->size);                             
}                                                         

int emptySymbolStack(SymbolStack this)                                  
{                                                         
	assert(this && "invalid SymbolStack in emptySymbolStack");                                            
	return !this->top;                                      
}                                                         

void * topSymbolStack(SymbolStack this)                                 
{                                                         
	assert(this && "invalid SymbolStack in topSymbolStack");                
	assert(this->top && "invalid SymbolStack top in topSymbolStack");       
	return this->top->object;
}

void * popSymbolStack(SymbolStack this)
{
	assert(this && "invalid SymbolStack in popSymbolStack");
	assert(this->top && "invalid SymbolStack top in popSymbolStack");
	Cell prev = this->top->prev;
	void  * old_object = this->top->object;
	free(this->top);
	this->top = prev;
	--(this->size);
	return old_object;
}

int getSizeSymbolStack(SymbolStack this) 
{
	return this->size;
}
