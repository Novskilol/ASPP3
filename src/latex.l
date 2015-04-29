%{
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
int numParenthesis;
char *mode[100];
int currentMode;
enum States{BEGINS,TITLES};
typedef enum States States;
States state;
void addToModes(char *yyt);
%}

A   [a-zA-Z_0-9]

%x ACCOL

%%
"\documentclass{article}"

"\usepackage{graphicx}"

"\\begin"\{    {
                printf("<div align=\"left\">");
		++numParenthesis;
		state=BEGINS;
                BEGIN ACCOL;
               }

"\\title"\{    {
                printf("<center>");
		++numParenthesis;
		state=TITLES;
                BEGIN ACCOL;
               }
 
<ACCOL>\{      {
                ++numParenthesis;
		ECHO;
               }
<ACCOL>\}      {
                --numParenthesis;
                if (numParenthesis==0)
		  {
		    switch(state)
		      {
		      case(BEGINS) :
			printf("</div>");
			break;
		      case(TITLES) :
			printf("</center>");
			break;
		      default:
			break;
		      }
		    BEGIN INITIAL;
		  }
		else
		  ECHO;
               }
<ACCOL>.       {ECHO;}
\%[^\n]*

"\n\n" {printf("\n");}

"\n" 

. {ECHO;}


%%



void addToModes(char *yyt){
  mode[currentMode]=yyt;
  //  \\\\ {printf("\n");}

  //\\ {printf(" ");}
  ++currentMode;
}
static int printBeginFile(int output) {
  int begin = open("html/begintex.html", O_RDONLY, 0444);
  char c;
  while(read(begin, &c, 1) > 0)
  printf("%c", c);
  return begin;
}

static int printEndFile(int output) {
  int end = open("html/endtex.html", O_RDONLY, 0444);
  char c;
  while(read(end, &c, 1) > 0)
  printf("%c", c);
  return end;
}

int main()    
{
  currentMode=0;
  numParenthesis=0;
  int output = open("doc.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);

  int begin = printBeginFile(output);
  
  yylex();
  
  int end = printEndFile(output);

  close(begin);
  close(end);
  close(output);

  return 0;    
}
