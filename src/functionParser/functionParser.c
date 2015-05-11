#include "functionParser.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <util.h>

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

void defaultReturnRule(FILE * f,char *data)
{
  fprintf(f,"<balise>Return</balise><br><description>%s</description><br>",data);
}

void defaultParamRule(FILE *f,char *data)
{
 fprintf(f,"<balise>Param</balise><br><description>%s</description><br>",data);
}

static void addLabel(char *labelName,FILE *f)
{
  fprintf(f,"<label class=%s></label>",labelName);
}

static void setRef(char *labelName,FILE *f)
{
   fprintf(f,"<balise>Référence</balise><br><reference class=%s>Voir %s</reference><br>",labelName,labelName);
}

void defaultBriefRule(FILE *f,char *data)
{
 fprintf(f,"<balise>Brief</balise><br><description>%s</description><br>",data);
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

int emptyFunctionParser(FunctionParser this)
{
  return this->sizeElements == 0 ;
}

void appendBeginDoc(char * fullFileName, char **filesArray, int size, char *fileName) {
  FILE *f=fopen(fullFileName,"w");
  appendFile(f, "assets/html/begin.html");
  appendSidebar(f, filesArray, size, fileName, false);
  fclose(f);
}

void appendEndDoc(char * fullFileName) {
    FILE *f=fopen(fullFileName,"a");
    appendFile(f, "assets/html/end.html");
    fclose(f);
}

static void parseRules(FunctionParser this,FILE *f)
{
  int i;
  for( i = 0 ; i < this->sizeElements ; ++i)
  {
    char *tmpName=this->elements[i]->name;
    char *tmpData=this->elements[i]->data;
    if (strcmp(tmpName,"@label") == 0 ){
      addLabel(tmpData,f);
      continue;
    }
    else if (strcmp(tmpName,"@ref") == 0 ){
      setRef(tmpData,f);
      continue;
    }
    int y;
    for( y = 0 ; y < this->sizeRules ; ++y)
      if ( strcmp(this->rules[y]->trigger,tmpName) == 0 )
	this->rules[y]->rule(f,tmpData);
   }
}

/**
 * @detail Print new html element that contains the prototype and the doxygen documentation if it exists
 * @param this         Our structure containing the parsed doxygen doc
 * @param name         Our identifier prototype
  * @param returnType   The return type of our function or NULL if it's a variable
 * @param id            The html class to give to our element, it should be the same id for the corresponding identifier
 */
static void printDocumentation(FunctionParser this, char *name, char *returnType, int id, TableObject to)
{
  // if (this->sizeElements <= 0) {
  //   fprintf(stdout,"<protoForTooltip class=\"%d\"  title=\"",id);
  //   if (returnType != NULL) {
  //     printf("<titre>%s %s</titre><br><br>",returnType,name );
  //   }
  //   else {
  //     printf("<titre>%s</titre><br><br>",name);
  //   }
  //   fprintf(stdout, "\"></protoForTooltip>");
  // }

  if (to != NULL) {

    fprintf(stdout,"<docuForTooltip class=\"%d\"  title=\"",id);

    if (to->declaration == NULL) {

      char * title;
      char * tmp;
      FILE * t = fopen("documentation.tmp", "w");

      if (returnType != NULL) {
        fprintf(t, "<titre>%s %s</titre><br><br>", returnType, name);
      }
      else {
        fprintf(t, "<titre>%s</titre><br><br>", name);
      }

      parseRules(this, t);


      to->declaration = title;
    }

    fprintf(stdout, "%s", to->declaration);

    parseRules(this,stdout);
    fprintf(stdout, "\"></docuForTooltip>");
  }

else {

}

}

void parseVar(FunctionParser this,char *varName,char *fileName,int id)
{
  //fprintf(stderr,"%s",varName);
 char * fullFileName;
  if (fileName == NULL) {
    fullFileName = "output/doc.html";
  }
  else {
    fullFileName = concat(fileName, ".doc.html");
  }

  FILE *f=fopen(fullFileName,"a");
  free(fullFileName);


  fprintf(f,"<div class=\"doc\">");
  fprintf(f,"<titre>%s</titre><br><br>",varName);
  parseRules(this,f);
  fprintf(f,"</div>");
  fclose(f);

  printDocumentation(this,varName,NULL,id,NULL);
}

void parseFunction(FunctionParser this, char *functionName,char *returnType, char *fileName, int id, TableObject to)
{
  /* We do not create a function block if function has no specific comment */
  if  ( this->sizeElements <= 0 ) {
    printDocumentation(this, functionName, returnType, id, to);
    return;
  }
  char * fullFileName;
  if (fileName == NULL)
    fullFileName = "output/doc.html";
  else
    fullFileName = concat(fileName, ".doc.html");

  FILE *f=fopen(fullFileName,"a");
  free(fullFileName);

  fprintf(f,"<div class=\"doc\">");
  fprintf(f,"<titre>%s %s</titre><br><br>",returnType,functionName);
  parseRules(this,f);
  fprintf(f,"</div>");
  fclose(f);

  printDocumentation(this, functionName, returnType, id, to);
 }

 void setDefaultRules(FunctionParser this)
 {
  setRuleForStatement(this,"@return",defaultReturnRule);
  setRuleForStatement(this,"@brief",defaultBriefRule);
  setRuleForStatement(this,"@param",defaultParamRule);
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

