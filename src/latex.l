%{
#include "latex.tab.h"
#include "symbolStack.h"

int numParenthesis;
enum States{BEGINS,TITLES,AUTHOR,NONE};
typedef enum States States;
States state;
SymbolStack stouck;
%}

%option nounput noinput

A   [a-zA-Z_0-9]

%x ACCOL
%x ACCOLEFF

%%
"\\documentclass{article}"

"\\textbf"\{    {
                 ++numParenthesis;
                 printf("<b>");
		 char *st=strdup("</b>");
		 pushSymbolStack(stouck,st);
                 BEGIN ACCOL;		 
	        }

"\\backslash"   {
                 printf("\\");
                }

"\\author"\{    {
                printf("<center><font size=\"4\">");
		++numParenthesis;
		state=AUTHOR;
                BEGIN ACCOL;
               }
  
"\\usepackage{graphicx}"

\{             {
                return '{';
               }

\}             {
                return '}';
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
		    char *jamb=topSymbolStack(stouck);
		    printf("%s",jamb);
		    popSymbolStack(stouck);
		    free(jamb);
		    if(emptySymbolStack(stouck))
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
		      case(AUTHOR) :			
			printf("</center></font>");
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
<ACCOL>\\\\           {printf("<br>");}

<ACCOL>"\\textbf"\{   {
                        ++numParenthesis;
		        printf("<b>");
			char *st=strdup("</b>");
			pushSymbolStack(stouck,st);		 
		      }

<ACCOL>"\\textit"\{   {
                        ++numParenthesis;
		        printf("<i>");
			char *st=strdup("</i>");
			pushSymbolStack(stouck,st);		 
		      }

<ACCOL>.              {ECHO;return CONTENT;}
\%[^\n]*

\\\\ {printf("<br>");}

"\n\n" {printf("<br>");}

"\n" 

. {ECHO;}

