%{
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>
#include "symbolStack.h"
  
extern int yylex();
extern int yylex_destroy();
 
void yyerror(char *);
%}

%union{
  char *s;
}


%token <s> CONTENT

%start init

%%


init : CONTENT init
     | beginstate init
     |
     ;

content : CONTENT content
        |
        ;

beginstate : '{' content '}'
           ;

%%


static int printBeginFile(int output) {
  int begin = open("assets/html/begintex.html", O_RDONLY, 0444);
  char c;
  while(read(begin, &c, 1) > 0)
  printf("%c", c);
  return begin;
}

static int printEndFile(int output) {
  int end = open("assets/html/endtex.html", O_RDONLY, 0444);
  char c;
  while(read(end, &c, 1) > 0)
  printf("%c", c);
  return end;
}

int main(int argc, char *argv[])
{
  int output = open("doc.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);

  int begin = printBeginFile(output);
  
  yyparse();
  
  int end = printEndFile(output);

  close(begin);
  close(end);
  close(output);
  
  yylex_destroy();
  return 0;
}
