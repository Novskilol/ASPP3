%{
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
%}

%%


"\n\n" {printf("\n");}
"\n"
. {ECHO;}


%%

int main()    
{
  int output = open("doc.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);

  yylex();

  close(output);

  return 0;    
}
