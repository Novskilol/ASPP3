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
#include <stdbool.h>
#include "symbolStack.h"
  
extern int yylex();
extern int yylex_destroy();

void verify_end(char *s);

int numsection;
int numsubsection;
int numenumerate;
int columns;
bool lockArray;

enum modes{ENUMERATEMODE,ITEMIZEMODE,TABULARMODE,NONE};
enum modes mode;

SymbolStack stouck;
void yyerror(char *);
%}

%union{
  char *s;
}


%token <s> CONTENT BACKSLASH AUTHOR USEPACKAGE DOCUMENTCLASS TITLE
%token <s> BEGINS DOCUMENT ENDS ABSTRACT TEXTIT TEXTBF SECTION EQUATION
%token <s> SUBSECTION ENUMERATE ITEM ITEMIZE TABULAR BREAKLINE EQUATIONETOILE
 
%type <s> begin_env_types

%start init

%%


init : 
     | content_s init
     | title_s init
     | begin_s {printf("<br>");} init end_s {printf("<br>");} init
     | author_s init
     | ital_s init
     | bold_s init
     | section_s {printf("<br>");} init
     | subsection_s {printf("<br>");} init
     | ITEM		{
       	    		 if(mode==ENUMERATEMODE)
			    {
			    numenumerate++;
			    printf("<br>%i. ",numenumerate);
			    }
			 if(mode==ITEMIZEMODE)
			    {
			    printf("<br>つ ◕_◕ ༽つ ");
			    }
		  	 }
			 init
			 
     ;

subsection_s : SUBSECTION {
	    	     	  numsubsection++;
	    	    	  printf("<div align=\"left\"><font size=\"5\">");
                    	  printf("%i.%i  ",numsection,numsubsection);
		    	  }
			  accolades_std
			  {
			  printf("</div></font>");
		     	  }
			
	     ;
section_s : SECTION {
	    	     numsubsection = 0;
		     numsection++;
	    	     printf("<div align=\"left\"><font size=\"6\">");
                     printf("%i  ",numsection);
		     }
		     accolades_std
		     {
		     printf("</div></font>");
		     }
          ;

end_s : ENDS accolades_end
      | ENDS '{' TABULAR '}' {
      	     	 	      printf("</table>");
			      mode=NONE;
			      columns=0;
			      }
      ;

accolades_end : '{' begin_env_types '}' {
	      	    		    	 verify_end($2);
                                         if (strcmp($2,"abstract")==0)
                                             {
					      printf("</div>");
                                             }
					 if (strcmp($2,"enumerate")==0)
                                             {
					     mode=NONE;
                                             }
					 if (strcmp($2,"itemize")==0)
                                             {
					     mode=NONE;
                                             }
					 if (strcmp($2,"tabular")==0)
                                             {
					     printf("</table>");
					     mode=NONE;
                                             }     
                                         }
              ;

begin_s : BEGINS accolades_begin
	| BEGINS '{' TABULAR '}' '{' content_tab '}'	{
	  	     	     	     		 	lockArray=false;
							mode=TABULARMODE;
							printf("<table border=\"1\"><tr>");
					      		}
						
        ;
	
content_tab : content_tab CONTENT {
	      		  	  if (*$2=='l'||*$2=='c'||*$2=='m')
	      		          columns++;
			          }
	    | 
            ;



accolades_begin  : '{' begin_env_types '}' {
                                             if (strcmp($2,"abstract")==0)
                                             {
                                              printf("<font size=\"4\"><div align=\"center\">\
                                                      <b>Abstract</b></font></div><div class=\"abstract\">");
                                             }
					     if (strcmp($2,"enumerate")==0)
                                             {
					      numenumerate=0;
					      mode=ENUMERATEMODE;
                                             }
					     if (strcmp($2,"itemize")==0)
                                             {
					      mode=ITEMIZEMODE;
                                             }
                                             pushSymbolStack(stouck,$2);
                                           }
                 ;

begin_env_types : DOCUMENT
                | ABSTRACT
		| EQUATION
		| EQUATIONETOILE
		| ENUMERATE
		| ITEMIZE
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

content_s :  CONTENT	      {
	    	      	      if(mode==TABULARMODE&&(*$1=='&'))
				{
				printf("</td>");
				printf("<td>");
			        }
			      else if(mode==TABULARMODE)
			      {
				if (lockArray==false)
				{
				   lockArray=true;
				   printf("<td>");
				   printf("%s", $1);
				}
				else
				  printf("%s", $1);
			      }
			      else
				printf("%s", $1);
			      }
			      
			      content_s
			      
          | begin_env_types {printf("%s", $1);} content_s
	  | BREAKLINE {
	    	      if(mode==TABULARMODE)
		      {
			lockArray=false;
			printf("</td>");
		        printf("</tr><tr>");
		      }
		      else
			printf("<br>");
		      }
		      content_s 
	  |
          ;

accolades_std : '{'  content_s  '}'
 

%%


void verify_end(char *s)
{
  
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
  mode=NONE;
  columns=0;
  numsection=0;
  numsubsection=0;
  numenumerate=0;
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
