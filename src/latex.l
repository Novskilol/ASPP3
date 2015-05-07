%{
#include "latex.tab.h"

%}

%option yylineno
%option nounput noinput

A   [a-zA-Z_0-9]

%x ACCOL
%x ACCOLEFF

%%
"\\maketitle"    {
                }

"\\documentclass{article}"

"\\textbf"      {
                 return TEXTBF;		 
	        }

"\\textit"      {
                 return TEXTIT;		 
	        }

"\\section"     {
                 return SECTION;
                }

"\\subsection"  {
                 return SUBSECTION;
                }

"\\item"	{
		return ITEM;
		}

"itemize"    	{
		 yylval.s = strdup(yytext);
	  	 return ITEMIZE;
		}
		
"tabular"    	{
		 yylval.s = strdup(yytext);
	  	 return TABULAR;
		}		
		
"equation"      {
		 yylval.s = strdup(yytext);
                 return EQUATION;
                }
		
"equation\*"    {
		 yylval.s = strdup(yytext);
                 return EQUATIONETOILE;
                }
		
"enumerate"     {
		 yylval.s = strdup(yytext);
                 return ENUMERATE;
                }
		
"\\backslash"   {
                 return BACKSLASH;
                }

"\\begin"       {                 
                 return BEGINS;
                }

"\\end"         {
                  return ENDS;
                }

"\\author"      {
                 return AUTHOR;
                }

"document"     {
                 yylval.s = strdup(yytext);
                 return DOCUMENT;
               }
"abstract"     {
                 yylval.s = strdup(yytext);
                 return ABSTRACT;
               }
  
"\\usepackage{graphicx}"

\{             {
                return '{';
               }

\}             {
                return '}';
               }

"\\title"      {
                return TITLE;
               }

\%[^\n]*

\\\\ {return BREAKLINE;}

"\n\n" {printf("<br>");}

"\n" 

. {yylval.s = strdup(yytext);return CONTENT;}

%%

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}