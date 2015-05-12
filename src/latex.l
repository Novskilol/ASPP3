%{
#include "latex.tab.h"
#include <stdbool.h>
bool verbatLock=false;
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
                      yylval.s = yytext;
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
                yylval.s = yytext;
                if(verbatLock==false)
                  verbatLock=true;
                else
                  verbatLock=false;
                if(verbatLock==true)
                {
                  BEGIN VERBATIMODEBR;
                }
		return VERBATIM;
		}

"itemize"    	{
		 yylval.s = yytext;
	  	 return ITEMIZE;
		}
		
"tabular"    	{
		 yylval.s = yytext;
	  	 return TABULAR;
		}		
		
"equation"      {
		 yylval.s = yytext;
                 return EQUATION;
                }
		
"equation\*"    {
		 yylval.s = yytext;
                 return EQUATIONETOILE;
                }
		
"enumerate"     {
		 yylval.s = yytext;
                 return ENUMERATE;
                }

"\\label"       {
                 return LABEL;
                }

"\\ref"         {
                 return REF;
                }
		
"\\backslash"   {
                 printf("\\");
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
                 yylval.s = yytext;
                 return DOCUMENT;
               }
"abstract"     {
                 yylval.s = yytext;
                 return ABSTRACT;
               }
  
"\\usepackage{graphicx}" 
"\\usepackage{amsmath}" 

\\\{           {
                 yylval.s = yytext+1;return CONTENT;
               }

\\\}           {
                 yylval.s = yytext+1;return CONTENT;
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

. {yylval.s = yytext;return CONTENT;}

%%

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}
