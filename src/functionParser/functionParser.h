#ifndef FUNCTION_PARSER_H
#define FUNCTION_PARSER_H

#include <stdio.h> // Included for FILE *
#include <symbolTable.h>


typedef struct functionParser * FunctionParser;

typedef void (*FunParserRule) (FILE *,char *);

FunctionParser createFunctionParser();

void addStatement(FunctionParser this,char *statementName,char *data);

void parseFunction(FunctionParser this,char *functionName,char *returntype, char *fileName,int id, TableObject to);

void resetFunctionParser(FunctionParser this);

void destroyFunctionParser(FunctionParser this);

void setRuleForStatement(FunctionParser this,char *statementName,FunParserRule rule);

void setDefaultRules(FunctionParser this);

void appendBeginDoc();

void appendEndDoc();

int emptyFunctionParser(FunctionParser this);

void parseVar(FunctionParser this,char *varName,char *filename,int id,TableObject to);

/*
  Default rules functions
 */
void defaultReturnRule(FILE*,char*);

void defaultBriefRule(FILE*,char *);

void defaultParamRule(FILE*,char *);

#endif
