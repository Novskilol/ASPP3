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

void verify_end(char *s);
void section_add();

int numsection;

SymbolStack stouck;
void yyerror(char *);
%}

%union{
  char *s;
}


%token <s> CONTENT BACKSLASH AUTHOR USEPACKAGE DOCUMENTCLASS TITLE
%token <s> BEGINS DOCUMENT ENDS ABSTRACT TEXTIT TEXTBF SECTION

%type <s> begin_env_types

%start init

%%


init : content_s init
     | title_s init
     | begin_s init end_s init
     | author_s init
     | ital_s init
     | bold_s init
     | section_s init
     |
     ;
section_s : SECTION {printf("<div align=\"left\"><font size=\"6\">");
                     printf("%i  ",numsection);} accolades_std
		     {section_add();printf("</div></font>");}
          ;

end_s : ENDS accolades_end
      ;

accolades_end : '{' begin_env_types '}' {verify_end($2);
                                         if (strcmp($2,"abstract")==0)
                                             {
					      printf("</div>");
                                             }
                                         }
              ;

begin_s : BEGINS accolades_begin
        ;

accolades_begin  : '{' begin_env_types '}' {
                                             if (strcmp($2,"abstract")==0)
                                             {
                                              printf("<font size=\"4\"><div align=\"center\">\
                                                      <b>Abstract</b></font></div><div class=\"abstract\">");
                                             }
                                            pushSymbolStack(stouck,$2);
                                           }
                 ;

begin_env_types : DOCUMENT
                | ABSTRACT
                ;

author_s : AUTHOR {printf("<center><font size=\"4\">");} accolades_std
		  {printf("</center></font>");}
         ;

title_s : TITLE {printf("<center><font size=\"10\">");} accolades_std
                {printf("</center></font>");}
        ;

ital_s : TEXTIT {printf("<i>");} accolades_std
                {printf("</i>");}
       ;

bold_s : TEXTBF {printf("<b>");} accolades_std
                {printf("</b>");}
       ;

content_s : content_s CONTENT {printf("%s", $2);}
          | begin_env_types
	  |
          ;

accolades_std : '{'  content_s  '}'
 

%%


void verify_end(char *s)
{
  
}

void section_add()
{
  numsection++;
}

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
  numsection=1;
  stouck=createSymbolStack();
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
