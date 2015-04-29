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

    #include "grammar.tab.h"
    #include "commun/commun.h"
    #include "functionParser.h"
    extern int sym_type(const char *);  /* returns type from symbol table */
    extern void yyerror(const char *);  /* prints grammar violation message */
    extern int yylineno;

    #define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

    static void comment(void);
    static void directive(void);
    static int check_type(void);
    static void begin_block_comment();
    static void end_block_comment();
    void saveStatementName(char **dest,char *src);
    char *tmpStatementName;

%}

%option yylineno nounput

%x NEWLINE
%s FOR_S
%x COMMENT COMMENT_ARGS

%%

"/*"                        { comment(); }
"/**"                       {   
    fprintf(stderr,"OUHIH");                           
    resetFunctionParser(functionParser); 
    BEGIN COMMENT; 
    begin_block_comment(); 
}
<COMMENT,COMMENT_ARGS>"*/"  { 
    BEGIN INITIAL; 
    end_block_comment(); 
}
<COMMENT>"\\return"         { 
    saveStatementName(&tmpStatementName,"\\return");
    fprintf(stderr,"LOLOLOLO %s",tmpStatementName);
    BEGIN COMMENT_ARGS; 
}
<COMMENT>"\\param"          { 
    saveStatementName(&tmpStatementName,"\\param");
    fprintf(stderr,"LOLOLOLO %s",tmpStatementName);
    BEGIN COMMENT_ARGS; 
}
<COMMENT>"\\brief"          { 
    saveStatementName(&tmpStatementName,"\\brief");
    fprintf(stderr,"LOLOLOLO %s",tmpStatementName);
    BEGIN COMMENT_ARGS; 
}
<COMMENT_ARGS>.*\n          {
    addStatement(functionParser,tmpStatementName,yytext);
    free(tmpStatementName);
    BEGIN COMMENT; 
}
<COMMENT>.|\n               ;

"//".*                  { printf("<comment>%s</comment>", yytext); }
"#"                     { directive(); }

"auto"					{ ECHO; return(AUTO); }
"break"					{ yylval.s = yytext; return(BREAK); }
"case"					{ yylval.s = yytext; return(CASE); }
"char"					{ yylval.s = yytext; return(CHAR); }
"const"					{ ECHO; return(CONST); }
"continue"				{ yylval.s = yytext; return(CONTINUE); }
"default"				{ yylval.s = yytext; return(DEFAULT); }
"do"					{ yylval.s = yytext; return(DO); }
"double"				{ yylval.s = yytext; return(DOUBLE); }
"else"					{ yylval.s = yytext; return(ELSE); }
"enum"					{ ECHO; return(ENUM); }
"extern"				{ ECHO; return(EXTERN); }
"float"					{ yylval.s = yytext; return(FLOAT); }
"for"					{ 
    yylval.s = yytext;
    BEGIN FOR_S;
    return(FOR); 
}
"goto"					{ yylval.s = yytext; return(GOTO); }
"if"					{ yylval.s = yytext; return(IF); }
"inline"				{ ECHO; return(INLINE); }
"int"					{ yylval.s = yytext; return(INT); }
"long"					{ yylval.s = yytext; return(LONG); }
"register"				{ ECHO; return(REGISTER); }
"restrict"				{ ECHO; return(RESTRICT); }
"return"				{ yylval.s = yytext; return(RETURN); }
"short"					{ yylval.s = yytext; return(SHORT); }
"signed"				{ yylval.s = yytext; return(SIGNED); }
"sizeof"				{ ECHO; return(SIZEOF); }
"static"				{ yylval.s = yytext; return(STATIC); }
"struct"				{ ECHO; return(STRUCT); }
"switch"				{ yylval.s = yytext; return(SWITCH); }
"typedef"				{ ECHO; return(TYPEDEF); }
"union"					{ ECHO; return(UNION); }
"unsigned"				{ yylval.s = yytext; return(UNSIGNED); }
"void"					{ yylval.s = yytext; return(VOID); }
"volatile"				{ ECHO; return(VOLATILE); }
"while"					{ yylval.s = yytext; return(WHILE); }
"_Alignas"              { ECHO; return ALIGNAS; }
"_Alignof"              { ECHO; return ALIGNOF; }
"_Atomic"               { ECHO; return ATOMIC; }
"_Bool"                 { ECHO; return BOOL; }
"_Complex"              { yylval.s = yytext; return COMPLEX; }
"_Generic"              { ECHO; return GENERIC; }
"_Imaginary"            { yylval.s = yytext; return IMAGINARY; }
"_Noreturn"             { ECHO; return NORETURN; }
"_Static_assert"        { ECHO; return STATIC_ASSERT; }
"_Thread_local"         { ECHO; return THREAD_LOCAL; }
"__func__"              { ECHO; return FUNC_NAME; }

{L}{A}*					            { return check_type(); }
{HP}{H}+{IS}?				        { ECHO; return I_CONSTANT; }
{NZ}{D}*{IS}?				        { ECHO; return I_CONSTANT; }
"0"{O}*{IS}?				        { ECHO; return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		    { return I_CONSTANT; }
{D}+{E}{FS}?				        { ECHO; return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			    { ECHO; return F_CONSTANT; }
{D}+"."{E}?{FS}?		            { ECHO; return F_CONSTANT; }
{HP}{H}+{P}{FS}?		            { ECHO; return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			    { ECHO; return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			        { ECHO; return F_CONSTANT; }
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval.s = yytext; return STRING_LITERAL; }


<NEWLINE>{WS}*("}"|"{") {
    BEGIN INITIAL;
    yyless(yyleng-1);
}
<NEWLINE>{WS}*.		    {
    indentThat();
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
<FOR_S>";"              { ECHO; return ';'; }
";"					    { 
    ECHO; 
    printf(NEWLINE_C);
    BEGIN NEWLINE;
    return ';';
}
("{"|"<%")			    { return '{'; }
("}"|"%>")			    { return '}'; }
","					    { ECHO; return ','; }
":"					    { ECHO; return ':'; }
"="					    { ECHO; return '='; }
"("					    { ECHO; return '('; }
    ")"					    { ECHO; return ')'; }
("["|"<:")			    { ECHO; return '['; }
("]"|":>")			    { ECHO; return ']'; }
"."					    { ECHO; return '.'; }
"&"					    { ECHO; return '&'; }
"!"					    { ECHO; return '!'; }
"~"					    { ECHO; return '~'; }
"-"					    { ECHO; return '-'; }
"+"					    { ECHO; return '+'; }
"*"					    { ECHO; return '*'; }
"/"					    { ECHO; return '/'; }
"%"					    { ECHO; return '%'; }
"<"					    { ECHO; return '<'; }
">"					    { ECHO; return '>'; }
"^"					    { ECHO; return '^'; }
"|"					    { ECHO; return '|'; }
"?"					    { ECHO; return '?'; }
[ ]+                    { ECHO;}
{WS}				    {  /* whitespace separates tokens */ }
.					    { /* discard bad characters */ }

%%
int yywrap(void) { return 1; }

static void comment(void)
{
    int c;
    printf("<comment>/*");

    while ((c = input()) != 0) {
        if (c == '*') {
            while ((c = input()) == '*') 
            printf("%c", c);

            if (c == '/')
            printf("*/</comment>%s%s", NEWLINE_C, NEWLINE_C);
            return;

            if (c == 0)
            break;
        }
        else if (c == '<') {
            printf("&lt");
        }
        else if (c == '>') {
            printf("&gt");
        }
        else {
            printf("%c", c);
        }
    }
    yyerror("unterminated comment");
}

static void directive(void)
{
    int c;
    printf("<directive>#");

    while ((c = input()) != 0) {
        if (c == '\n') {
            printf("</directive>%s%s", NEWLINE_C, NEWLINE_C);
            return;
        }
        else if (c == '<') {
            printf("&lt");
        }
        else if (c == '>') {
            printf("&gt");
        }
        else {
            printf("%c", c);
        }
    }
    yyerror("unterminated comment");
}

static int check_type(void)
{
    switch (sym_type(yytext))
    {
        case TYPEDEF_NAME:                /* previously defined */
        yylval.s = yytext;
        return TYPEDEF_NAME;
        case ENUMERATION_CONSTANT:        /* previously defined */
        ECHO;
        return ENUMERATION_CONSTANT;
        default:                          /* includes undefined */
        yylval.s = yytext; //strcpy(malloc(sizeof(char)*strlen(yytext+1)),yytext);
        return IDENTIFIER;
    }
}

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}

void deleteIndent(){
    indent -= REGULAR_INDENT;
    BEGIN NEWLINE;
}
void addIndent(){
    indent += REGULAR_INDENT;
    BEGIN NEWLINE;
}
void beginLine()
{
    BEGIN NEWLINE;
}

static void begin_block_comment() {
    printf("<div class=\"doc\">%s", NEWLINE_C);
}

static void end_block_comment() {
    printf("%s</div>", NEWLINE_C);
}
void saveStatementName(char **dest,char *src)
{
  *dest=strcpy(malloc((strlen(src)+1)*sizeof(char)),src);

}
