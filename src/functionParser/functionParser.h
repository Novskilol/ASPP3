#ifndef FUNCTION_PARSER_H
#define FUNCTION_PARSER_H

#include <stdio.h> // Included for FILE *
#include <symbolTable.h>


typedef struct functionParser * FunctionParser;

typedef void (*FunParserRule) (FILE *,char *);

/**
 * @brief Create a function parser with no rules 
 * @ref{setDefaultRules}
 */
FunctionParser createFunctionParser();

void addStatement(FunctionParser this,char *statementName,char *data);

/**
 * @brief Create documentation and tooltip for a function
 */
void parseFunction(FunctionParser this,char *functionName,char *returntype, char *fileName,int id, TableObject to);

/**
 * @brief Reset the function parser , should be called every time parse function is called
 */
void resetFunctionParser(FunctionParser this);

void destroyFunctionParser(FunctionParser this);

/**
 * @brief Set a action triggered by statementName
 */
void setRuleForStatement(FunctionParser this,char *statementName,FunParserRule rule);

/**
 * @label{setDefaultRules}
 * @brief Set default rules to the function parser 
 * @ref{defaultReturnRule}
 * @ref{defaultBriefRule}
 * @ref{defaultParamRule}
 */
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


/**
 * @brief create tooltip for the function , if function/variable was documented previously parse it .
 * @param char *name , the function name or variable name
 * @param char *returnType  , NULL if its a variable, returntype otherwise
 * @param int id , the id (class) of the variable/function pointed by name 
 * @param TableObject to , obtained by searchFunctionSymbolTable
 */
void printDocumentation(FunctionParser this, char *name, char *returnType, int id, TableObject to);

#endif
