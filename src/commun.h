#ifndef COMMUN_H
#define COMMUN_H

#include <stdio.h>

#define NEWLINE_C "\n<br>"
#define SPACE_C "&nbsp"
#define REGULAR_INDENT 4

extern void addIndent();
extern void deleteIndent();
extern void beginLine();

void indentThat();

int indent;

#endif
