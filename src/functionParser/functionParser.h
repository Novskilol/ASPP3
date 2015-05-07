#ifndef FUNCTION_PARSER_H
#define FUNCTION_PARSER_H
#include <stdio.h> // Included for FILE *
typedef struct functionParser * FunctionParser;
typedef void (*FunParserRule) (FILE *,char *);
FunctionParser createFunctionParser();
void addStatement(FunctionParser this,char *statementName,char *data);
void parseFunction(FunctionParser this,char *functionName,char *returntype, char *fileName);
void resetFunctionParser(FunctionParser this);
void destroyFunctionParser(FunctionParser this);
void setRuleForStatement(FunctionParser this,char *statementName,FunParserRule rule);
void setDefaultRules(FunctionParser this);
void appendBeginDoc();
void appendEndDoc();


/*
  Default rules functions
 */
void defaultReturnRule(FILE*,char*);
void defaultBriefRule(FILE*,char *);
void defaultParamRule(FILE*,char *);
#endif
