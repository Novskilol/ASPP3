#include "functionParser.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#define DEFAULT_SIZE_MAX_ELEMENTS 5
#define DEFAULT_SIZE_MAX_RULES 5
typedef struct parserElement *ParserElement;
typedef struct parserRule *ParserRule;
struct functionParser{
  ParserElement *elements;
  ParserRule *rules;
  int sizeMaxElements;
  int sizeElements;
  int sizeRules;
  int sizeMaxRules;
};
struct parserRule{
  FunParserRule rule;
  char *trigger;

};
struct parserElement{
  char *name;
  char *data;
};
static int isFullFunctionParserRules(FunctionParser this)
{
  return this->sizeRules == this->sizeMaxRules;
}
static int isFullFunctionParserElements(FunctionParser this)
{
  return this->sizeElements == this->sizeMaxElements;
}
static void resizeRules(FunctionParser this)
{
  this->rules = realloc(this->rules,this->sizeMaxRules * 2);
  this->sizeMaxRules *= 2;
  
}
static void resizeElements(FunctionParser this)
{
  this->elements = realloc(this->elements,this->sizeMaxElements * 2);
  this->sizeMaxElements *= 2;
  
}
void resetFunctionParser(FunctionParser this)
{
   int i;

  for ( i = 0 ; i < this->sizeElements ; ++i)
    {
      free(this->elements[i]->name);
      free(this->elements[i]->data);      
      free(this->elements[i]);
    }
    
  
  this->sizeElements=0;
}
void destroyFunctionParser(FunctionParser this)
{
  int i;

  for ( i = 0 ; i < this->sizeElements ; ++i)
    {
      free(this->elements[i]->name);
      free(this->elements[i]->data);    
      free(this->elements[i]);
    }

  for ( i = 0 ; i < this->sizeRules ; ++i){
    free(this->rules[i]->trigger);
    free(this->rules[i]);

  }
  free(this->elements);
  free(this->rules);
  free(this);
    
}
void addStatement(FunctionParser this,char *statementName,char *data)
{
  if (isFullFunctionParserElements(this))
    resizeElements(this);
  
  ParserElement toBeAdded = malloc(sizeof(*toBeAdded));
  toBeAdded->name = strcpy(malloc((strlen(statementName)+1)*sizeof(char)),statementName);
toBeAdded->data = strcpy(malloc(sizeof(char)*(strlen(data)+1)),data);
  this->elements[this->sizeElements++] = toBeAdded;

}
void setRuleForStatement(FunctionParser this,char *statementName,FunParserRule rule)
{
  if (isFullFunctionParserRules(this))
    resizeRules(this);
  
  ParserRule toBeAdded = malloc(sizeof(*toBeAdded));
  toBeAdded->rule = rule;
  toBeAdded->trigger = strcpy(malloc(sizeof(char)*(strlen(statementName)+1)),statementName);
  this->rules[this->sizeRules++] = toBeAdded;
  

}
void parseFunction(FunctionParser this, char *functionName)
{
  if (this->sizeElements == 0 || this->sizeRules == 0 )
    return;

  FILE *f=fopen(functionName,"w");
  int i;
  for( i = 0 ; i < this->sizeElements ; ++i)
    {
      
      char *tmpName=this->elements[i]->name;
      char *tmpData=this->elements[i]->data;
      int y;
      for( y = 0 ; y < this->sizeRules ; ++y)
	if ( strcmp(this->rules[y]->trigger,tmpName) == 0 )
	  this->rules[y]->rule(f,tmpData);

    }
  fclose(f);

  
}
FunctionParser createFunctionParser()
{
  FunctionParser this=malloc(sizeof(*this));
  this->elements=malloc(sizeof(*this->elements)*DEFAULT_SIZE_MAX_ELEMENTS);
  this->rules = malloc(sizeof(*this->rules)*DEFAULT_SIZE_MAX_RULES);
  this->sizeElements=0;
  this->sizeRules=0;
  this->sizeMaxRules=DEFAULT_SIZE_MAX_RULES;
  this->sizeMaxElements=DEFAULT_SIZE_MAX_ELEMENTS;

  return this;
}
