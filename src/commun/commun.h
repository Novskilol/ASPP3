#ifndef COMMUN_H
#define COMMUN_H

#include <stdio.h>
#include "../symboleTable/symboleTable.h"
#include "functionParser.h"

#define NEWLINE_C "<br>\n"
#define SPACE_C "&nbsp"
#define REGULAR_INDENT 4

extern void addIndent();
extern void deleteIndent();
extern void beginLine();

void indentThat();

int indent;
SymboleTable symbol_table;
FunctionParser functionParser;
#endif
