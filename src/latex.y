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

enum modes{ENUMERATEMODE,ITEMIZEMODE,EQUATIONMODE,SECTIONSMODE,VERBATIMMODE,
	   EQUATIONETOILEMODE,TABULARMODE,LABELMODE,REFMODE,NONE};
enum modes mode;
enum modes mode2;
SymbolStack stouck;
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
			    printf("<br>%i. ",numenumerate);
			    }
			 if(mode==ITEMIZEMODE)
			    {
			    printf("<br>つ ◕_◕ つ ");
			    }
		  	 }
			 init
			 
     ;

subsection_s : SUBSECTION {
                          lockAlinea=false;
	    	     	  numsubsection++;
			  mode2=SECTIONSMODE;
			  numsubsubsection = 0;
	    	    	  printf("<div align=\"left\"><font size=\"5\">");
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
	    	    	  printf("<div align=\"left\"><font size=\"4\">");
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
	    	     printf("<div align=\"left\"><font size=\"6\">");
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
					 mode=NONE;
                                         }
              ;

begin_s :  BEGINS accolades_begin
	|  BEGINS '{' TABULAR '}' '{' content_tab '}'	{
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

label_s : LABEL {
                  mode = LABELMODE;
		  printf("<label class=\"");
	  	} accolades_std { printf("\"></label>"); }

        ;

ref_s : REF {
             mode = REFMODE;
	     printf("<reference class=\"");
	     }  accolades_std { printf("\">"); } 
                accolades_std { printf("</reference>"); }
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
                                             pushSymbolStack(stouck,$2);
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

author_s : AUTHOR {printf("<center><font size=\"4\">");} accolades_std
		  {printf("</center></font>");}
         ;

title_s : TITLE {
                 lockAlinea=false;
                 printf("<center><font size=\"10\">");
		} accolades_std
                {printf("</center></font>");}
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
		  CONTENT	      {
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
			      }
			      
			      
          | begin_env_types {printf("%s", $1);}
	  | BREAKLINE {
	    	      if(mode==TABULARMODE)
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

void writeContents()
{
  FILE *dest=fopen("doc.html","a");
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
  stouck=createSymbolStack();
  contentsfp=fopen("contents.html","w+");
  fprintf(contentsfp,"<br><font size=\"6\"><center>Table of contents</font></center><br>");
  int output = open("doc.html",O_WRONLY|O_TRUNC|O_CREAT,0666);  

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

  int output2 = open("doc.html",O_WRONLY|O_APPEND,0666);  

  dup2(output2,1);
  
  int end = printEndFile(output2);

  close(begin);
  close(end);
  close(output2);
  yylex_destroy();
  
  return 0;
}
