#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>

/**
 * @detail Copy the string src
 * @param  src The string to be copied
 * @return     The new allocated string
 */
char * copy(const char * src);

int fileSize(const char *fileName);

char *fileToChar(const char *fileName,int sizeFile);
/**
 * @detail Copy and replace every occurrence of the character 'bad' from the string s by 'rep'
 * @param  s   The source string, untouched
 * @param  bad The characted to be removed
 * @param  rep The replacement character
 * @return     The new allocated string
 */
char * replace(const char * s, char bad, const char * rep);

/**
 * @detail Print the content of the file src in the standard output
 * @param dest Where to write
 * @param src The file from where to read
 */
void appendFile(FILE * dest, char * src);

/**
 * @detail Add html code for sidebar, the number of element in the sidebar depends on the arguments passed to function main
 * @param dest       Where to write
 * @param filesArray Array of all the files passed to function main,
 * @param size       Size of filesArray
 * @param fileName   Current source file name
 * @param isCode     Whether we are generating a sidebar for a documentation file or a source/header file
 */
void appendSidebar(FILE * dest, char **filesArray, int size, char *fileName, bool isCode);

/**
 * @detail Allocate the appropriate memory concatenate two string
 * @return   The new concatenated string
 */
char *concat(const char *a,const char * b);

/**
 * @detail Destroy an allocated string, given as argument to the linked list function creation
 * @param a Our string to be freed
 */
void destroyChar(void *a);

/**
* @detail Compare two string, given to the linked list as argument function creation
* @return true if s1 and s2 are the same string
*/
int compareChar(void *s1, void *s2);

#endif
