#ifndef FUNCTION_PARSER_H
#define FUNCTION_PARSER_H
typedef struct functionParser * FunctionParser;

FunctionParser createFunctionParser();
void addStatement(FunctionParser this,char *statementName,char *data);
void parseFunction(FunctionParser this,char *functionName);
#endif
