#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


char * copy(const char *);

char * replace(const char *, char, const char *);

void appendFile(char *);

char *concat(const char *a,const char * b);

/*
 * Functions for CompareFunction and DestroyFunction , see SymboleList
 */
void destroyChar(void *a);

int compareChar(void *,void *);

#endif
