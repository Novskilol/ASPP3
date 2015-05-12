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
#include "util/util.h"
#include "commun/commun.h"

extern int yylex();
extern int yylex_destroy();

void verify_end(char *s);
void setContent();

int numsection;
int numsubsection;
int numenumerate;
int numequation;
int numsubsubsection;
int columns;
FILE *contentsfp;
bool contents;
bool lockArray;
bool lockAlinea;
void writeContents();

enum modes{ENUMERATEMODE,ITEMIZEMODE,EQUATIONMODE,SECTIONSMODE,VERBATIMMODE,AUTHORMODE,
	   EQUATIONETOILEMODE,TABULARMODE,LABELMODE,REFMODE,NONE};
enum modes mode;
enum modes mode2;
enum modes *modeget(char *s);
SymbolStack statesStack;
void yyerror(char *);
%}

%union{
  char *s;
}


%token <s> CONTENT BACKSLASH AUTHOR USEPACKAGE DOCUMENTCLASS TITLE
%token <s> BEGINS DOCUMENT ENDS ABSTRACT TEXTIT TEXTBF SECTION EQUATION
%token <s> SUBSECTION ENUMERATE ITEM ITEMIZE TABULAR BREAKLINE EQUATIONETOILE
%token <s> SUBSUBSECTION LABEL REF VERBATIM

%type <s> begin_env_types

%start init

%%


init :
     | content_s init
     | label_s init
     | ref_s init
     | title_s init
     | {printf("<br>");} begin_s init end_s {printf("<br>");} init
     | author_s init
     | ital_s init
     | bold_s init
     | {printf("<br>");} section_s {printf("<br>");} init
     | {printf("<br>");} subsection_s {printf("<br>");} init
     | {printf("<br>");} subsubsection_s {printf("<br>");} init
     | ITEM		{
                         lockAlinea=false;
       	    		 if(mode==ENUMERATEMODE)
			    {
			    numenumerate++;
			    printf("<br>%s%s%s%s%i. ",SPACE_C,SPACE_C,SPACE_C,SPACE_C,numenumerate);
			    }
			 if(mode==ITEMIZEMODE)
			    {
			    printf("<br>%s%s%s%s◕ ", SPACE_C,SPACE_C,SPACE_C,SPACE_C);
			    }
		  	 }
			 init

     ;

subsection_s : SUBSECTION {
                          lockAlinea=false;
	    	     	  numsubsection++;
			  mode2=SECTIONSMODE;
			  numsubsubsection = 0;
	    	    	  printf("<div style=\"color:#7CAFC2\" align=\"left\"><font size=\"5\">");
                    	  printf("%i.%i  ",numsection,numsubsection);
			  fprintf(contentsfp,"<div align=\"left\"><font size=\"5\">  %i.%i   ",
				  numsection,numsubsection);
			  fprintf(contentsfp,"<reference class=\"section%ia%i\">",numsection,numsubsection);
			  printf("<label class=\"section%ia%i\"></label>",numsection,numsubsection);
		    	  }
			  accolades_std
			  {
			  fprintf(contentsfp,"</reference>");
			  mode2=NONE;
			  fprintf(contentsfp,"</div></font><br>");
			  printf("</div></font>");
			  lockAlinea=true;
		     	  }

	     ;
subsubsection_s : SUBSUBSECTION {
                          lockAlinea=false;
			  mode2=SECTIONSMODE;
	    	     	  numsubsubsection++;
	    	    	  printf("<div style=\"color:#7CAFC2\" align=\"left\"><font size=\"4\">");
                    	  printf("%i.%i.%i  ",numsection,numsubsection,numsubsubsection);
			  fprintf(contentsfp,"<div align=\"left\"><font size=\"4\">      %i.%i.%i   ",numsection,
				  numsubsection,numsubsubsection);
			  fprintf(contentsfp,"<reference class=\"section%ia%ia%i\">",numsection,numsubsection,numsubsubsection);
			  printf("<label class=\"section%ia%ia%i\"></label>",numsection,numsubsection,numsubsubsection);
		    	  }
			  accolades_std
			  {
			  fprintf(contentsfp,"</reference>");
			  mode2=NONE;
			  fprintf(contentsfp,"</div></font><br>");
			  printf("</div></font>");
			  lockAlinea=true;
		     	  }

	     ;
section_s : SECTION {
                     lockAlinea=false;
                     mode2=SECTIONSMODE;
	    	     numsubsection = 0;
		     numsection++;
                     fprintf(contentsfp,"<div align=\"left\"><font size=\"6\">%i  ",numsection);
	    	     printf("<div style=\"color:#7CAFC2\" align=\"left\"><font size=\"6\">");
                     printf("%i  ",numsection);
		     fprintf(contentsfp,"<reference class=\"section%i\">",numsection);
		     printf("<label class=\"section%i\"></label>",numsection);
		     }
		     accolades_std
		     {
		     mode2=NONE;
		     fprintf(contentsfp,"</reference>");
		     fprintf(contentsfp,"</div></font><br>");
		     printf("</div></font>");
		     lockAlinea=true;
		     }
          ;

end_s : ENDS accolades_end
      | ENDS '{' TABULAR '}' {

      	     	 	      printf("</table>");
			      popSymbolStack(statesStack);
			      mode=*(enum modes*)topSymbolStack(statesStack);
			      columns=0;
			      }
      ;

accolades_end : '{' begin_env_types '}' {
	      	    		    	 verify_end($2);
                                         if (strcmp($2,"abstract")==0)
                                             {
					      printf("</div>");
                                             }
					 if (strcmp($2,"tabular")==0)
                                             {
					     printf("</table>");
                                             }
					 if (strcmp($2,"equation")==0)
                                             {
					       printf("</p></i><p class=\"alignright\">(%i)</p></div><div style=\"clear: both;\"></div></font>",numequation);
                                             }
					 if (strcmp($2,"verbatim")==0)
                                             {
					      printf("</xmp></div></CODE>");
                                             }
					 if (strcmp($2,"equation*")==0)
                                             {
					       printf("</i></div></font>");
                                             }
					 free(popSymbolStack(statesStack));
					 if (getSizeSymbolStack(statesStack)!=0)
					   mode=*(enum modes*)topSymbolStack(statesStack);
					 else
					   mode=NONE;
                                         }
              ;

begin_s :  BEGINS accolades_begin
	|  BEGINS '{' TABULAR '}' '{' content_tab '}'	{
	  	     	     	     		 	lockArray=false;
							enum modes *modeIn=modeget($3);
							pushSymbolStack(statesStack,modeIn);
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

label_s : LABEL {
                  enum modes *modeIn=modeget($1);
		  pushSymbolStack(statesStack,modeIn);
                  mode = LABELMODE;
		  printf("<label class=\"");
	  	} accolades_std { printf("\"></label>"); 
		                  free(popSymbolStack(statesStack));
				  if (getSizeSymbolStack(statesStack)!=0)
				    mode=*(enum modes*)topSymbolStack(statesStack);
				  else
				    mode=NONE;}

        ;

ref_s : REF {
             enum modes *modeIn=modeget($1);
             pushSymbolStack(statesStack,modeIn);
             mode = REFMODE;
	     printf("<reference class=\"");
	     }  accolades_std { printf("\">"); }
                accolades_std { printf("</reference>");
		                free(popSymbolStack(statesStack));
				if (getSizeSymbolStack(statesStack)!=0)
				  mode=*(enum modes*)topSymbolStack(statesStack);
				else
				  mode=NONE; 
		              }
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
					     if (strcmp($2,"verbatim")==0)
                                             {
					      printf("<CODE><div class=\"codelatex\"><xmp>");
					      mode=VERBATIMMODE;
                                             }
					     if (strcmp($2,"equation")==0)
                                             {
					       numequation++;
					       printf("<div id=\"equation\"><i><font size=\"4\">\
                                                       <p class=\"alignleft\">  </p>\
                                                       <p class=\"aligncenter\">");
					       mode=EQUATIONMODE;
                                             }
					     if (strcmp($2,"equation*")==0)
                                             {
					       printf("<font size=\"4\">\
                                                        <div align=\"center\"><i>");
					       mode=EQUATIONETOILEMODE;
                                             }
					     enum modes *modeIn=modeget($2);
                                             pushSymbolStack(statesStack,modeIn);
                                           }
                 ;

begin_env_types : DOCUMENT
                | ABSTRACT
		| EQUATION
		| EQUATIONETOILE
		| ENUMERATE
		| ITEMIZE
                | VERBATIM
                ;

author_s : AUTHOR {mode=AUTHORMODE;printf("<center><font size=\"4\">");} accolades_std
                  {mode=NONE;printf("</center></font>");}
         ;

title_s : TITLE {
                 lockAlinea=false;
                 printf("<div style=\"color:#DC9656\"><center><font size=\"10\">");
		} accolades_std
                {printf("</font></center></div><br>");}
        ;

ital_s : TEXTIT {printf("<i>");} accolades_std
                {printf("</i>");}
       ;

bold_s : TEXTBF {printf("<b>");} accolades_std
                {printf("</b>");}
       ;

content_s :  {
                if(lockAlinea==true)
		    {
		      printf("%s%s%s",SPACE_C, SPACE_C, SPACE_C);
		      lockAlinea=false;
		    }
              }
		  CONTENT     {
                              if(lockAlinea==true)
				printf("   ");
	    	      	      if(mode==TABULARMODE&&(*$2=='&'))
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
				   printf("%s", $2);
				}
				else
				  printf("%s", $2);
			      }
			      else if(mode==REFMODE||mode==LABELMODE)
			      {
				if (*$2!=':')
				  {
				  printf("%s", $2);
				  }
			      }
			      else
				printf("%s", $2);
			      if(mode2==SECTIONSMODE)
				{
				   fprintf(contentsfp,"%s",$2);
				}
			      //free($2);
			      }


          | begin_env_types {printf("%s", $1);}
	  | BREAKLINE {
	              if(mode==AUTHORMODE)
			{
	                lockAlinea=false;
			printf("</center><br><center>");
			}
	    	      else if(mode==TABULARMODE)
		      {
			lockArray=false;
			printf("</td>");
		        printf("</tr><tr>");
		      }
		      else
		      {
			lockAlinea=true;
			printf("<br>");
		      }
		      }
          | TABULAR   {printf("%s",$1);}
          ;

accolades_std : '{'  repeat_cont  '}'

repeat_cont : content_s repeat_cont
            |
            ;


%%

void setContent()
{
  contents=true;
}

enum modes *modeget(char *s)
{
  enum modes *ret=malloc(sizeof(enum modes));
  *ret=NONE;
  if (strcmp(s,"equation")==0) 
    *ret=EQUATIONMODE;
  if (strcmp(s,"equation*")==0) 
    *ret=EQUATIONETOILEMODE;
  if (strcmp(s,"label")==0) 
    *ret=LABELMODE;
  if (strcmp(s,"verbatim")==0) 
    *ret=VERBATIMMODE;
  if (strcmp(s,"tabular")==0) 
    *ret=TABULARMODE;
  if (strcmp(s,"itemize")==0) 
    *ret=ITEMIZEMODE;
  if (strcmp(s,"author")==0) 
    *ret=AUTHORMODE;
  if (strcmp(s,"enumerate")==0) 
    *ret=ENUMERATEMODE;
  if (strcmp(s,"ref")==0) 
    *ret=REFMODE;
  if (strcmp(s,"document")==0) 
    *ret=NONE;
  return ret;
}

void writeContents()
{
  FILE *dest=fopen("latex.html","a");
  appendFile(dest,"contents.html");
  fclose(dest);
}

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
  mode2=NONE;
  lockAlinea=false;
  contents=false;
  columns=0;
  numsection=0;
  numsubsection=0;
  numequation=0;
  numsubsubsection=0;
  numenumerate=0;
  statesStack=createSymbolStack();
  contentsfp=fopen("contents.html","w+");
  fprintf(contentsfp,"<br><font size=\"6\"><center>Table of contents</font></center><br>");
  int output = open("latex.html",O_WRONLY|O_TRUNC|O_CREAT,0666);

  dup2(output, 1);

  int begin = printBeginFile(output);

  yyparse();

  fflush(stdout);
  close(output);
  fclose(contentsfp);

  if (contents==true)
   {
     writeContents();
   }

  int output2 = open("latex.html",O_WRONLY|O_APPEND,0666);

  dup2(output2,1);

  int end = printEndFile(output2);

  while(!emptySymbolStack(statesStack))
    popSymbolStack(statesStack);
  destroySymbolStack(statesStack);
  close(begin);
  close(end);
  close(output2);
  yylex_destroy();

  return 0;
}
