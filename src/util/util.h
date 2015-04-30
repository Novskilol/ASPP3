#ifndef COMMUN_H
#define COMMUN_H

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

#endif
