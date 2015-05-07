%{
#include "latex.tab.h"
%}

%option nounput noinput

A   [a-zA-Z_0-9]

%x ACCOL
%x ACCOLEFF

%%
"\maketitle"    {
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

\\\\ {printf("<br>");}

"\n\n" {printf("<br>");}

"\n" 

. {yylval.s = strdup(yytext);return CONTENT;}

