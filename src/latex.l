%{
#include "latex.tab.h"

%}

%option yylineno
%option nounput noinput

A   [a-zA-Z_0-9]

%x VERBATIMODE
%x VERBATIMODEBR

%%
<VERBATIMODEBR>\} {
                    BEGIN VERBATIMODE;
                    return '}';
                  }

<VERBATIMODEBR>.|\n {
                      BEGIN INITIAL;
                      yylval.s = strdup(yytext);
                      return CONTENT;
                    }


<VERBATIMODE>.|\n {ECHO;}

<VERBATIMODE>"\\end"         {
                              BEGIN INITIAL;
                              return ENDS;
                             }

"\\maketitle"   {
                }

"\\documentclass{article}"

"\\textbf"      {
                 return TEXTBF;		 
	        }

"\\tableofcontents"      {
                         setContent();		 
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

"\\subsubsection"  {
                   return SUBSUBSECTION;
                   }


"\\item"	{
		return ITEM;
		}

"verbatim"	{
                yylval.s = strdup(yytext);
                BEGIN VERBATIMODEBR;
		return VERBATIM;
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

"\\label"       {
                 return LABEL;
                }

"\\ref"         {
                 return REF;
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
"\\usepackage{amsmath}" 

\\\{           {
                 yylval.s = strdup(yytext+1);return CONTENT;
               }

\\\}           {
                 yylval.s = strdup(yytext+1);return CONTENT;
               }

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

"\n\n" {return BREAKLINE;}

"\n" 

. {yylval.s = strdup(yytext);return CONTENT;}

%%

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}
