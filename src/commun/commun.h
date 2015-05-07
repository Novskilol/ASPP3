#ifndef COMMUN_H
#define COMMUN_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#include "../symbolTable/symbolTable.h"
#include "../functionParser/functionParser.h"
#include "../symbolList/symbolList.h"
#define NEWLINE_C "<br>\n"
#define SPACE_C "&nbsp"
#define LESS_T_C "&lt"
#define GREATER_T_C "&gt"
#define REGULAR_INDENT 4

extern void addIndent();
extern void deleteIndent();
extern void beginLine();

void indentThat();

SymbolTable symbolTable;
SymbolList typeSymbolList;
FunctionParser functionParser;
int indentSpacing;

#endif
