%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include <stdio.h>
#include "grammar.tab.h"

extern void yyerror(const char *);  /* prints grammar violation message */
extern int yylineno;

extern int sym_type(const char *);  /* returns type from symbol table */

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */
#define _REGULARINDENT 4

static void comment(void);
static int check_type(void);
int indent;
void indentThat();

%}

%option yylineno
%x DEBUTLIGNE
%%
"/*"                                    { comment(); }
"//".*                                  { /* consume //-comment */ }

"auto"					{ ECHO; return(AUTO); }
"break"					{ ECHO; return(BREAK); }
"case"					{ ECHO; return(CASE); }
"char"					{ ECHO; return(CHAR); }
"const"					{ ECHO; return(CONST); }
"continue"				{ ECHO; return(CONTINUE); }
"default"				{ ECHO; return(DEFAULT); }
"do"					{ ECHO; return(DO); }
"double"				{ ECHO; return(DOUBLE); }
"else"					{ ECHO; return(ELSE); }
"enum"					{ ECHO; return(ENUM); }
"extern"				{ ECHO; return(EXTERN); }
"float"					{ ECHO; return(FLOAT); }
"for"					{ ECHO; return(FOR); }
"goto"					{ ECHO; return(GOTO); }
"if"					{ ECHO; return(IF); }
"inline"				{ ECHO; return(INLINE); }
"int"					{ ECHO; return(INT); }
"long"					{ ECHO; return(LONG); }
"register"				{ ECHO; return(REGISTER); }
"restrict"				{ ECHO; return(RESTRICT); }
"return"				{ ECHO; return(RETURN); }
"short"					{ ECHO; return(SHORT); }
"signed"				{ ECHO; return(SIGNED); }
"sizeof"				{ ECHO; return(SIZEOF); }
"static"				{ ECHO; return(STATIC); }
"struct"				{ ECHO; return(STRUCT); }
"switch"				{ ECHO; return(SWITCH); }
"typedef"				{ ECHO; return(TYPEDEF); }
"union"					{ ECHO; return(UNION); }
"unsigned"				{ ECHO; return(UNSIGNED); }
"void"					{ ECHO; return(VOID); }
"volatile"				{ ECHO; return(VOLATILE); }
"while"					{ ECHO; return(WHILE); }
"_Alignas"                              { ECHO; return ALIGNAS; }
"_Alignof"                              { ECHO; return ALIGNOF; }
"_Atomic"                               { ECHO; return ATOMIC; }
"_Bool"                                 { ECHO; return BOOL; }
"_Complex"                              { ECHO; return COMPLEX; }
"_Generic"                              { ECHO; return GENERIC; }
"_Imaginary"                            { ECHO; return IMAGINARY; }
"_Noreturn"                             { ECHO; return NORETURN; }
"_Static_assert"                        { ECHO; return STATIC_ASSERT; }
"_Thread_local"                         { ECHO; return THREAD_LOCAL; }
"__func__"                              { ECHO; return FUNC_NAME; }

{L}{A}*					{ ECHO; return check_type(); }

{HP}{H}+{IS}?				{ ECHO; return I_CONSTANT; }
{NZ}{D}*{IS}?				{ ECHO; return I_CONSTANT; }
"0"{O}*{IS}?				{ ECHO; return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ return I_CONSTANT; }

{D}+{E}{FS}?				{ ECHO; return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ ECHO; return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ ECHO; return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ ECHO; return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ ECHO; return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ ECHO; return F_CONSTANT; }
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ return STRING_LITERAL; }
<DEBUTLIGNE>{WS}*[^}]			{
					indentThat();
					BEGIN INITIAL;
					yyless(yyleng-1);
					}
<DEBUTLIGNE>{WS}*"}"                    {
                                        
                                        fprintf(stderr,"FINE");
                                        BEGIN INITIAL;
                                        yyless(yyleng-1);


                                        }
"..."					{ ECHO; return ELLIPSIS; }
">>="					{ ECHO; return RIGHT_ASSIGN; }
"<<="					{ ECHO; return LEFT_ASSIGN; }
"+="					{ ECHO; return ADD_ASSIGN; }
"-="					{ ECHO; return SUB_ASSIGN; }
"*="					{ ECHO; return MUL_ASSIGN; }
"/="					{ ECHO; return DIV_ASSIGN; }
"%="					{ ECHO; return MOD_ASSIGN; }
"&="					{ ECHO; return AND_ASSIGN; }
"^="					{ ECHO; return XOR_ASSIGN; }
"|="					{ ECHO; return OR_ASSIGN; }
">>"					{ ECHO; return RIGHT_OP; }
"<<"					{ ECHO; return LEFT_OP; }
"++"					{ ECHO; return INC_OP; }
"--"					{ ECHO; return DEC_OP; }
"->"					{ ECHO; return PTR_OP; }
"&&"					{ ECHO; return AND_OP; }
"||"					{ ECHO; return OR_OP; }
"<="					{ ECHO; return LE_OP; }
">="					{ ECHO; return GE_OP; }
"=="					{ ECHO; return EQ_OP; }
"!="					{ ECHO; return NE_OP; }
";"					{ 
                                        ECHO; 
                                        printf("\n");
                                        BEGIN DEBUTLIGNE;
                                        return ';';
                                        }
("{"|"<%")				{
                                        ECHO;
                                        printf("\n");
                                        indent+=_REGULARINDENT;
                                        BEGIN DEBUTLIGNE;
                                        return '{';
                                        }
("}"|"%>")				{
                                        indent-=_REGULARINDENT;
                                        indentThat();
                                        ECHO;
                                        printf("\n");
                                        BEGIN DEBUTLIGNE; 
                                        return '}';
                                        }
","					{ ECHO; return ','; }
":"					{ ECHO; return ':'; }
"="					{ ECHO; return '='; }
"("					{ ECHO; return '('; }
")"					{ ECHO; return ')'; }
("["|"<:")				{ ECHO; return '['; }
("]"|":>")				{ ECHO; return ']'; }
"."					{ ECHO; return '.'; }
"&"					{ ECHO; return '&'; }
"!"					{ ECHO; return '!'; }
"~"					{ ECHO; return '~'; }
"-"					{ ECHO; return '-'; }
"+"					{ ECHO; return '+'; }
"*"					{ ECHO; return '*'; }
"/"					{ ECHO; return '/'; }
"%"					{ ECHO; return '%'; }
"<"					{ ECHO; return '<'; }
">"					{ ECHO; return '>'; }
"^"					{ ECHO; return '^'; }
"|"					{ ECHO; return '|'; }
"?"					{ ECHO; return '?'; }
[ ]+                            { ECHO;}
{WS}					{ fprintf(stderr, "OK\n"); /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%
void indentThat(){
     int i=0;
     for(;i<indent;i++){
     	     printf(" ");
	     }
}

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}

static int check_type(void)
{
    switch (sym_type(yytext))
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}

void yyerror(const char *s)
{
	
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}

