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

/**
 * @detail Increase the indentation level, called whenever we get in a code block, change flex mode for NEWLINE
 */
extern void addIndent();

/**
 * @detail Decrease the indentation level, called whenever we get out of a code block, change flex mode for NEWLINE
 */
extern void deleteIndent();

/**
 * @detail Lex function : change flex mode for NEWLINE
 */
extern void beginLine();

/**
 * @detail Print as much as space as needed to get a correct indentation in html
 */
void indentThat();

/**
 * @brief Where we store all our identifiers, for each code block there is a corresponding linked lisk, all the lists are stored in a Stack
 */
SymbolTable symbolTable;

/**
 * @brief Where we store all our user type (struct and typedef)
 */
SymbolList typeSymbolList;

/**
 * @brief Structure used to store function and variable doxygen documentation
 */
FunctionParser functionParser;

/**
 * @brief Contains the numbre of space that we have to print to correct indentation level
 */
int indentSpacing;

/**
 * @brief The current file
 */
char *fileName;


#endif
