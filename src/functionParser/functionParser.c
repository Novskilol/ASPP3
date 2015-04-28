#include "functionParser.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#define DEFAULT_SIZE_MAX 10
typedef struct parserElement *ParserElement;
struct functionParser{
  ParserElement *elements;
  int sizeMax;
  int size;
};
struct parserElement{
  char *name;
  char *data;
};
static int isFull(FunctionParser this)
{
  return this->size==this->sizeMax;
}
static void resize(FunctionParser this)
{
  this->elements=realloc(this->elements,this->sizeMax*2);
  this->sizeMax*=2;
  
}
void addStatement(FunctionParser this,char *statementName,char *data)
{
  if (isFull(this))
    resize(this);
  
  ParserElement toBeAdded=malloc(sizeof(*toBeAdded));
  toBeAdded->name=strcpy(malloc(sizeof(strlen(statementName)+1)),statementName);
  toBeAdded->data=strcpy(malloc(sizeof(strlen(data)+1)),data);
  this->elements[this->size++]=toBeAdded;

}
void parseFunction(FunctionParser this, char *functionName)
{
  FILE *f=fopen(functionName,"w");
  int i;
  for( i = 0 ; i < this->size ; ++i)
    {
      char *tmpName=this->elements[i]->name;
      char *tmpData=this->elements[i]->data;
      fwrite(tmpName,sizeof(char),strlen(tmpName),f);
      fwrite(tmpData,sizeof(char),strlen(tmpData),f);
    }
  fclose(f);
  
}
FunctionParser createFunctionParser()
{
  FunctionParser this=malloc(sizeof(*this));
  this->elements=malloc(sizeof(*this->elements)*DEFAULT_SIZE_MAX);
  this->size=0;
  this->sizeMax=DEFAULT_SIZE_MAX;
  return this;
}
