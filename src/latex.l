%{
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "symboleStack.h"
int numParenthesis;
enum States{BEGINS,TITLES,NONE};
typedef enum States States;
States state;
SymboleStack stouck;
%}

A   [a-zA-Z_0-9]

%x ACCOL
%x ACCOLEFF

%%
"\\documentclass{article}"

"\\textbf"\{    {
                 ++numParenthesis;
                 printf("<b>");
		 char *st=strdup("</b>");
		 pushSymboleStack(stouck,st);
                 BEGIN ACCOL;		 
	        }

"\\backslash"   {
                 printf("\\");
                }


"\\usepackage{graphicx}"

"\\begin"\{    {
                printf("<h3>");
		++numParenthesis;
		state=BEGINS;
                BEGIN ACCOL;
               }
  
"\\end"\{      {
                ++numParenthesis;
                BEGIN ACCOLEFF;
               }

"\\title"\{    {
                printf("<center><font size=\"10\">");
		++numParenthesis;
		state=TITLES;
                BEGIN ACCOL;
               }
<ACCOLEFF>[^[\{|\}]]*
  
<ACCOLEFF>\{   {
                ++numParenthesis;
               }

<ACCOLEFF>\}   {
                --numParenthesis;
		if (numParenthesis==0)
		  {
		    BEGIN INITIAL;
		  }
               }
 
<ACCOL>\{      {
                ++numParenthesis;
		ECHO;
               }
<ACCOL>\}      {
                --numParenthesis;
		if(state==NONE) 
		  {
		    char *jamb=topSymboleStack(stouck);
		    printf("%s",jamb);
		    popSymboleStack(stouck);
		    free(jamb);
		    if(emptySymboleStack(stouck))
		      BEGIN INITIAL;
		    break;
		  }
                if (numParenthesis==0)
		  {
		    switch(state)
		      {
		      case(TITLES) :
			printf("</center></font>");
			state=NONE;
			BEGIN INITIAL;
			break;
		      case(BEGINS) :			
			printf("</h3>");
			state=NONE;
			BEGIN INITIAL;
			break;
		      default:
			break;
		      }
		  }
		else
		  ECHO;
               }

<ACCOL>"\\textbf"\{   {
                        ++numParenthesis;
		        printf("<b>");
			char *st=strdup("</b>");
			pushSymboleStack(stouck,st);		 
		      }

<ACCOL>"\\textit"\{   {
                        ++numParenthesis;
		        printf("<i>");
			char *st=strdup("</i>");
			pushSymboleStack(stouck,st);		 
		      }

<ACCOL>.       {ECHO;}
\%[^\n]*

\\\\ {printf("\n");}

"\n\n" {printf("<br>");}

"\n" 

. {ECHO;}


%%

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
  state=NONE;
  stouck=createSymboleStack();
  
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
