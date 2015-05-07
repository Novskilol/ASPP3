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
    //static void directive(void);
    static int checkType(void);
    static char * replaceString(const char *);
    void saveStatementName(char **dest,char *src);
    char *tmpStatementName;

%}

%option yylineno nounput

%s FOR_S
%x NEWLINE COMMENT COMMENT_ARGS COMMENT_DOUBLE_SLASH


%%

"/*"                        { comment(); }
"/**"                       { BEGIN COMMENT; }
<COMMENT,COMMENT_ARGS>"*/"  { BEGIN INITIAL; }
<COMMENT>"@return"         {
    saveStatementName(&tmpStatementName,"\\return");
    BEGIN COMMENT_ARGS;
}
<COMMENT>"@param"          {
    saveStatementName(&tmpStatementName,"\\param");
    BEGIN COMMENT_ARGS;
}
<COMMENT>"@brief"          {
    saveStatementName(&tmpStatementName,"\\brief");
    BEGIN COMMENT_ARGS;
}
<COMMENT_ARGS>.*\n          {
    addStatement(functionParser,tmpStatementName,yytext);
    free(tmpStatementName);
    BEGIN COMMENT;
}
<COMMENT>.|\n               ;

"//"                         {
    printf("<comment>//");
    BEGIN COMMENT_DOUBLE_SLASH;
}
<COMMENT_DOUBLE_SLASH>"<"    { printf(LESS_T_C); }
<COMMENT_DOUBLE_SLASH>">"    { printf(GREATER_T_C); }
<COMMENT_DOUBLE_SLASH>"\n"   {
    printf("</comment>%s", NEWLINE_C);
    BEGIN NEWLINE;
}
<COMMENT_DOUBLE_SLASH>.      { ECHO; }

"#".*                   { /* discard directives */ }

"auto"					{ yylval.s = yytext; return(AUTO); }
"break"					{ yylval.s = yytext; return(BREAK); }
"case"					{ yylval.s = yytext; return(CASE); }
"char"					{ yylval.s = yytext; return(CHAR); }
"const"					{ yylval.s = yytext; return(CONST); }
"continue"				{ yylval.s = yytext; return(CONTINUE); }
"default"				{ yylval.s = yytext; return(DEFAULT); }
"do"					{ yylval.s = yytext; return(DO); }
"double"				{ yylval.s = yytext; return(DOUBLE); }
"else"					{ yylval.s = yytext; return(ELSE); }
"enum"					{ yylval.s = yytext; return(ENUM); }
"extern"				{ yylval.s = yytext; return(EXTERN); }
"float"					{ yylval.s = yytext; return(FLOAT); }
"for"					{
    yylval.s = yytext;
    BEGIN FOR_S;
    return(FOR);
}
"goto"					{ yylval.s = yytext; return(GOTO); }
"if"					{ yylval.s = yytext; return(IF); }
"inline"				{ yylval.s = yytext; return(INLINE); }
"int"					{ yylval.s = yytext; return(INT); }
"long"					{ yylval.s = yytext; return(LONG); }
"register"				{ yylval.s = yytext; return(REGISTER); }
"restrict"				{ yylval.s = yytext; return(RESTRICT); }
"return"				{ yylval.s = yytext; return(RETURN); }
"short"					{ yylval.s = yytext; return(SHORT); }
"signed"				{ yylval.s = yytext; return(SIGNED); }
"sizeof"				{ yylval.s = yytext; return(SIZEOF); }
"static"				{ yylval.s = yytext; return(STATIC); }
"struct"				{ yylval.s = yytext; return(STRUCT); }
"switch"				{ yylval.s = yytext; return(SWITCH); }
"typedef"				{ yylval.s = yytext; return(TYPEDEF); }
"union"					{ yylval.s = yytext; return(UNION); }
"unsigned"				{ yylval.s = yytext; return(UNSIGNED); }
"void"					{ yylval.s = yytext; return(VOID); }
"volatile"				{ yylval.s = yytext; return(VOLATILE); }
"while"					{ yylval.s = yytext; return(WHILE); }
"_Alignas"              { yylval.s = yytext; return ALIGNAS; }
"_Alignof"              { yylval.s = yytext; return ALIGNOF; }
"_Atomic"               { yylval.s = yytext; return ATOMIC; }
"_Bool"                 { yylval.s = yytext; return BOOL; }
"_Complex"              { yylval.s = yytext; return COMPLEX; }
"_Generic"              { yylval.s = yytext; return GENERIC; }
"_Imaginary"            { yylval.s = yytext; return IMAGINARY; }
"_Noreturn"             { yylval.s = yytext; return NORETURN; }
"_Static_assert"        { yylval.s = yytext; return STATIC_ASSERT; }
"_Thread_local"         { yylval.s = yytext; return THREAD_LOCAL; }
"__func__"              { yylval.s = yytext; return FUNC_NAME; }

{L}{A}*					            { return checkType(); }
{HP}{H}+{IS}?				        { yylval.s = yytext; return I_CONSTANT; }
{NZ}{D}*{IS}?				        { yylval.s = yytext; return I_CONSTANT; }
"0"{O}*{IS}?				        { yylval.s = yytext; return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		    { yylval.s = yytext; return I_CONSTANT; }
{D}+{E}{FS}?				        { yylval.s = yytext; return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			    { yylval.s = yytext; return F_CONSTANT; }
{D}+"."{E}?{FS}?		            { yylval.s = yytext; return F_CONSTANT; }
{HP}{H}+{P}{FS}?		            { yylval.s = yytext; return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			    { yylval.s = yytext; return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			        { yylval.s = yytext; return F_CONSTANT; }
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ yylval.s = replaceString(yytext); return STRING_LITERAL; }

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
"<"					    { printf(LESS_T_C); return '<'; }
">"					    { printf(GREATER_T_C); return '>'; }
"^"					    { ECHO; return '^'; }
"|"					    { ECHO; return '|'; }
"?"					    { ECHO; return '?'; }
[ ]+                    { ECHO;}
{WS}				    { /* whitespace separates tokens */ }
.					    { /* discard bad characters */ }

%%
int yywrap(void) { return 1; }

static void comment(void)
{
    int c;

    printf("%s<comment>/*", NEWLINE_C);
    while ((c = input()) != 0) {
        if (c == '*') {
            while ((c = input()) == '*')
            printf("%c", c);

            if (c == '/')
            printf("*/</comment>%s%s", NEWLINE_C, NEWLINE_C);
            BEGIN NEWLINE;
            return;

            if (c == 0)
            break;
        }
        else {
            if (c == '<') {
                printf(LESS_T_C);
            }
            else if (c == '>') {
                printf(GREATER_T_C);
            }
            else if (c == '\n') {
                printf(NEWLINE_C);
                BEGIN NEWLINE;
            }
            else {
                printf("%c", c);
            }
        }
    }
    yyerror("unterminated comment");
}

//static void directive(void)
//{
//    int c;
//    printf("<directive>#");
//
//    while ((c = input()) != 0) {
//        if (c == '\n') {
//            printf("</directive>%s", NEWLINE_C);
//            return;
//        }
//        else if (c == '<') {
//            printf(LESS_T_C);
//        }
//        else if (c == '>') {
//            printf(GREATER_T_C);
//        }
//        else {
//            printf("%c", c);
//        }
//    }
//    yyerror("unterminated directive");
//}

static int checkType(void)
{
    switch (sym_type(yytext))
    {
        case TYPEDEF_NAME:                /* previously defined */
        yylval.s = yytext;
        return TYPEDEF_NAME;
        case ENUMERATION_CONSTANT:        /* previously defined */
        yylval.s = yytext;
        return ENUMERATION_CONSTANT;
        default:                          /* includes undefined */
        yylval.s = yytext;
        TableObject t;
        if ( (t=searchSymbolList(typeSymbolList,yylval.s)) != NULL)
             return VOID;
        return IDENTIFIER;
    }
}

static char * replaceString(const char * s)
{
    char * tmp = replace(s, '<', "&lt");
    char * res = replace(tmp, '>', "&gt");
    free(tmp);
    return res; // free in grammar.y
}

void yyerror(const char *s)
{
	fflush(stdout);
	fprintf(stderr, "line : %d msg: %s\n",yylineno, s);
}

void deleteIndent()
{
    indentSpacing -= REGULAR_INDENT;
    BEGIN NEWLINE;
}
void addIndent()
{
    indentSpacing += REGULAR_INDENT;
    BEGIN NEWLINE;
}
void beginLine()
{
    BEGIN NEWLINE;
}

void saveStatementName(char **dest,char *src)
{
  *dest=strcpy(malloc((strlen(src)+1)*sizeof(char)),src);
}
