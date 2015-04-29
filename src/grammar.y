%{		

  #include <sys/types.h>		
  #include <sys/stat.h>
  #include <string.h>
  #include <fcntl.h>		
  #include <stdio.h>
  #include <stdbool.h>
  #include <unistd.h>
  #include <math.h>

  #include "commun/commun.h"
  #include "symbolTable/symbolTable.h"
  #include "functionParser.h"
  #include "util/util.h"

  extern int yylex();

  void yyerror(char *);
  void openBraces();
  void closeBraces();
  void printType(char *);
  void addNewSymbol(char *);
  bool searchSymbol(char *);  
  char * createClassString(char *);
  char * createDeclarationString(char *);

  char * typeName = NULL;
  bool typeLock = false;
  int indentLock = 0;
  int indentLvl = 0;
  int uniqueId = 1;

  %}

  %union{
   char *s;
 }

 %token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
 %token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
 %token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
 %token XOR_ASSIGN OR_ASSIGN
 %token ELLIPSIS
 
 %token <s> IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
 %token	<s> TYPEDEF_NAME ENUMERATION_CONSTANT
 %token	<s> TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
 %token	<s> CONST RESTRICT VOLATILE
 %token	<s> BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
 %token	<s> COMPLEX IMAGINARY 
 %token	<s> STRUCT UNION ENUM 
 %token	<s> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
 %token	<s> ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

 %start translation_unit

 %%

 primary_expression
 : identifier
 | constant
 | string
 | '(' expression ')'
 | generic_selection
 ;

 constant
 : I_CONSTANT	            { printf("%s\n", $1); }	/* includes character_constant */
 | F_CONSTANT             { printf("%s\n", $1); }
 | ENUMERATION_CONSTANT	  { printf("%s\n", $1); }  /* after it has been defined as such */
 ;

 enumeration_constant		/* before it has been defined as such */
 : identifier
 ;

 string
 : string_literal
 | FUNC_NAME { printf("%s\n", $1); }
 ;

 generic_selection
 : GENERIC '(' assignment_expression ',' generic_assoc_list ')' { printf("%s\n", $1); }
 ;

 generic_assoc_list
 : generic_association
 | generic_assoc_list ',' generic_association
 ;

 generic_association
 : type_name ':' assignment_expression
 | default ':' assignment_expression
 ;

 postfix_expression
 : primary_expression
 | postfix_expression '[' expression ']'
 | postfix_expression '(' ')'
 | postfix_expression '(' argument_expression_list ')'
 | postfix_expression '.' identifier
 | postfix_expression PTR_OP identifier
 | postfix_expression INC_OP
 | postfix_expression DEC_OP
 | '(' type_name ')' maybeNewlineForward '{' initializer_list newlineBackward '}'
 | '(' type_name ')' maybeNewlineForward '{' initializer_list ',' newlineBackward '}'
 ;

 argument_expression_list
 : assignment_expression
 | argument_expression_list ',' assignment_expression
 ;

 unary_expression
 : postfix_expression
 | INC_OP unary_expression
 | DEC_OP unary_expression
 | unary_operator cast_expression
 | sizeof unary_expression 
 | sizeof '(' type_name ')' 
 | ALIGNOF '(' type_name ')' { printf("%s\n", $1); }
 ;

 unary_operator
 : '&'
 | '*'
 | '+'
 | '-'
 | '~'
 | '!'
 ;

 cast_expression
 : unary_expression
 | '(' type_name ')' cast_expression
 ;

 multiplicative_expression
 : cast_expression
 | multiplicative_expression '*' cast_expression
 | multiplicative_expression '/' cast_expression
 | multiplicative_expression '%' cast_expression
 ;

 additive_expression
 : multiplicative_expression
 | additive_expression '+' multiplicative_expression
 | additive_expression '-' multiplicative_expression
 ;

 shift_expression
 : additive_expression
 | shift_expression LEFT_OP additive_expression
 | shift_expression RIGHT_OP additive_expression
 ;

 relational_expression
 : shift_expression
 | relational_expression '<' shift_expression
 | relational_expression '>' shift_expression
 | relational_expression LE_OP shift_expression
 | relational_expression GE_OP shift_expression
 ;

 equality_expression
 : relational_expression
 | equality_expression EQ_OP relational_expression
 | equality_expression NE_OP relational_expression
 ;

 and_expression
 : equality_expression
 | and_expression '&' equality_expression
 ;

 exclusive_or_expression
 : and_expression
 | exclusive_or_expression '^' and_expression
 ;

 inclusive_or_expression
 : exclusive_or_expression
 | inclusive_or_expression '|' exclusive_or_expression
 ;

 logical_and_expression
 : inclusive_or_expression
 | logical_and_expression AND_OP inclusive_or_expression
 ;

 logical_or_expression
 : logical_and_expression
 | logical_or_expression OR_OP logical_and_expression
 ;

 conditional_expression
 : logical_or_expression
 | logical_or_expression '?' expression ':' conditional_expression
 ;

 assignment_expression
 : conditional_expression
 | unary_expression assignment_operator assignment_expression
 ;

 assignment_operator
 : '='
 | MUL_ASSIGN
 | DIV_ASSIGN
 | MOD_ASSIGN
 | ADD_ASSIGN
 | SUB_ASSIGN
 | LEFT_ASSIGN
 | RIGHT_ASSIGN
 | AND_ASSIGN
 | XOR_ASSIGN
 | OR_ASSIGN
 ;

 expression
 : assignment_expression
 | expression ',' assignment_expression
 ;

 constant_expression
 : conditional_expression	/* with constraints */
 ;

 declaration
 : declaration_specifiers ';'
 | declaration_specifiers init_declarator_list ';'
 | static_assert_declaration
 ;

 declaration_specifiers
 : storage_class_specifier declaration_specifiers
 | storage_class_specifier
 | type_specifier declaration_specifiers
 | type_specifier
 | type_qualifier declaration_specifiers
 | type_qualifier
 | function_specifier declaration_specifiers
 | function_specifier
 | alignment_specifier declaration_specifiers
 | alignment_specifier
 ;

 init_declarator_list
 : init_declarator
 | init_declarator_list ',' init_declarator
 ;

 init_declarator
 : declarator '=' initializer
 | declarator 
 ;

 storage_class_specifier
 : TYPEDEF	      { printf("%s\n", $1); } /* identifiers must be flagged as TYPEDEF_NAME */
 | EXTERN         { printf("%s\n", $1); }
 | static
 | THREAD_LOCAL   { printf("%s\n", $1); }
 | AUTO           { printf("%s\n", $1); }
 | REGISTER       { printf("%s\n", $1); }
 ;

 type_specifier
 : VOID       { printType($1); }
 | CHAR       { printType($1); }
 | SHORT      { printType($1); }
 | INT        { printType($1); }
 | LONG       { printType($1); }
 | FLOAT      { printType($1); }
 | DOUBLE     { printType($1); }
 | SIGNED     { printType($1); }
 | UNSIGNED   { printType($1); }
 | BOOL       { printType($1); }
 | COMPLEX    { printType($1); }
 | IMAGINARY  { printType($1); }
 | atomic_type_specifier       { printType($<s>1); }
 | struct_or_union_specifier   { printType($<s>1); }
 | enum_specifier              { printType($<s>1); }
 | TYPEDEF_NAME	               { printType($1); }
 ;

 struct_or_union_specifier
 : struct_or_union maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 | struct_or_union identifier maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 | struct_or_union identifier
 ;

 struct_or_union
 : STRUCT   { printf("%s\n", $1); }
 | UNION    { printf("%s\n", $1); }
 ;

 struct_declaration_list
 : struct_declaration
 | struct_declaration_list struct_declaration
 ;

 struct_declaration
 : specifier_qualifier_list ';'	/* for anonymous struct/union */
 | specifier_qualifier_list struct_declarator_list ';'
 | static_assert_declaration
 ;

 specifier_qualifier_list
 : type_specifier specifier_qualifier_list
 | type_specifier
 | type_qualifier specifier_qualifier_list
 | type_qualifier
 ;

 struct_declarator_list
 : struct_declarator
 | struct_declarator_list ',' struct_declarator
 ;

 struct_declarator
 : ':' constant_expression
 | declarator ':' constant_expression
 | declarator
 ;

 enum_specifier
 : enum maybeNewlineForward '{' enumerator_list newlineBackward '}'
 | enum maybeNewlineForward '{' enumerator_list ',' newlineBackward '}'
 | enum identifier maybeNewlineForward '{' enumerator_list newlineBackward '}'
 | enum identifier maybeNewlineForward '{' enumerator_list ',' newlineBackward '}'
 | enum identifier
 ;

 enum
 : ENUM { printf("%s\n", $1); }
 ;

 enumerator_list
 : enumerator
 | enumerator_list ',' enumerator
 ;

 enumerator	/* identifiers must be flagged as ENUMERATION_CONSTANT */
 : enumeration_constant '=' constant_expression
 | enumeration_constant
 ;

 atomic_type_specifier
 : ATOMIC '(' type_name ')' { printf("%s\n", $1); }
 ;

 type_qualifier
 : CONST      { printf("%s", $1); }
 | RESTRICT   { printf("%s", $1); }
 | VOLATILE   { printf("%s", $1); }
 | ATOMIC     { printf("%s", $1); }
 ;

 function_specifier
 : INLINE     { printf("%s\n", $1); }
 | NORETURN   { printf("%s\n", $1); }
 ;

 alignment_specifier
 : alignas '(' type_name ')'
 | alignas '(' constant_expression ')'
 ;

 declarator
 : pointer direct_declarator
 | direct_declarator
 ;

 direct_declarator
 : IDENTIFIER { typeLock = true; addNewSymbol($1); }
 | '(' declarator ')' 
 | direct_declarator '[' ']' 
 | direct_declarator '[' '*' ']' 
 | direct_declarator '[' static type_qualifier_list assignment_expression ']' 
 | direct_declarator '[' static assignment_expression ']' 
 | direct_declarator '[' type_qualifier_list '*' ']' 
 | direct_declarator '[' type_qualifier_list static assignment_expression ']' 
 | direct_declarator '[' type_qualifier_list assignment_expression ']' 
 | direct_declarator '[' type_qualifier_list ']' 
 | direct_declarator '[' assignment_expression ']' 
 | direct_declarator '(' parameter_type_list ')' 
 { typeLock = false; parseFunction(functionParser,$<s>1, typeName); }
 | direct_declarator '(' ')' 
 { typeLock = false; parseFunction(functionParser,$<s>1, typeName); }
 | direct_declarator '(' identifier_list ')' 
 { typeLock = false; parseFunction(functionParser,$<s>1, typeName); }
 ;


 pointer
 : '*' type_qualifier_list pointer
 | '*' type_qualifier_list
 | '*' pointer
 | '*'
 ;

 type_qualifier_list
 : type_qualifier
 | type_qualifier_list type_qualifier
 ;


 parameter_type_list
 : parameter_list ',' ELLIPSIS
 | parameter_list
 ;

 parameter_list
 : parameter_declaration
 | parameter_list ',' parameter_declaration
 ;

 parameter_declaration
 : declaration_specifiers declarator
 | declaration_specifiers abstract_declarator
 | declaration_specifiers
 ;

 identifier_list
 : identifier
 | identifier_list ',' identifier
 ;

 type_name
 : specifier_qualifier_list abstract_declarator
 | specifier_qualifier_list
 ;

 abstract_declarator
 : pointer direct_abstract_declarator
 | pointer
 | direct_abstract_declarator
 ;

 direct_abstract_declarator
 : '(' abstract_declarator ')'
 | '[' ']'
 | '[' '*' ']'
 | '[' static type_qualifier_list assignment_expression ']'
 | '[' static assignment_expression ']'
 | '[' type_qualifier_list static assignment_expression ']'
 | '[' type_qualifier_list assignment_expression ']'
 | '[' type_qualifier_list ']'
 | '[' assignment_expression ']'
 | direct_abstract_declarator '[' ']'
 | direct_abstract_declarator '[' '*' ']'
 | direct_abstract_declarator '[' static type_qualifier_list assignment_expression ']'
 | direct_abstract_declarator '[' static assignment_expression ']'
 | direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
 | direct_abstract_declarator '[' type_qualifier_list static assignment_expression ']'
 | direct_abstract_declarator '[' type_qualifier_list ']'
 | direct_abstract_declarator '[' assignment_expression ']'
 | '(' ')'
 | '(' parameter_type_list ')'
 | direct_abstract_declarator '(' ')'
 | direct_abstract_declarator '(' parameter_type_list ')'
 ;

 initializer
 : maybeNewlineForward '{' initializer_list newlineBackward '}'
 | maybeNewlineForward '{' initializer_list ',' newlineBackward '}'
 | assignment_expression
 ;

 initializer_list
 : designation initializer
 | initializer
 | initializer_list ',' designation initializer
 | initializer_list ',' initializer
 ;

 designation
 : designator_list '='
 ;

 designator_list
 : designator
 | designator_list designator
 ;

 designator
 : '[' constant_expression ']'
 | '.' identifier
 ;

 static_assert_declaration
 : STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';' { printf("%s\n", $1); }
 ;

 statement
 : labeled_statement
 | compound_statement
 | expression_statement
 | selection_statement
 | iteration_statement
 | jump_statement
 ;

 labeled_statement
 : identifier ':' statement
 | case constant_expression ':' newlineForward statement newlineBackwardHidden
 | default ':' statement
 ;

 compound_statement
 : maybeNewlineForward '{' newlineBackward '}'
 | maybeNewlineForward '{'  block_item_list newlineBackward '}'
 ;

 block_item_list
 : block_item
 | block_item_list block_item
 ;

 block_item
 : declaration
 | statement
 ;

 expression_statement
 : ';'
 | expression ';'
 ;


 selection_statement
 : if '(' expression ')' newlineForward statement newlineBackwardHidden else  newlineForward statement newlineBackwardHidden
 | if '(' expression ')' newlineForward statement newlineBackwardHidden
 | switch '(' expression ')' newlineForward statement newlineBackwardHidden
 ;

 iteration_statement
 : while '(' expression ')' newlineForward statement newlineBackwardHidden
 | do newlineForward statement while '(' expression ')' ';'
 | for '(' expression_statement expression_statement ')' newlineForward statement newlineBackwardHidden
 | for '(' expression_statement expression_statement expression ')' newlineForward statement newlineBackwardHidden
 | for '(' declaration expression_statement ')' newlineForward statement newlineBackwardHidden
 | for '(' declaration expression_statement expression ')' newlineForward statement newlineBackwardHidden
 ;

 jump_statement
 : goto identifier ';'
 | continue ';'
 | break ';'
 | return ';'
 | return expression ';'
 ;

 translation_unit
 : external_declaration
 | translation_unit external_declaration
 ;

 external_declaration
 : function_definition
 | declaration 
 ;

 function_definition
 : declaration_specifiers declarator  declaration_list compound_statement
 | declaration_specifiers declarator  compound_statement
 ;

 declaration_list
 : declaration
 | declaration_list declaration
 ;

 newlineForward
 : {
   addIndent();
   printf(NEWLINE_C);
   indentLock += 1;
   indentLvl += 1;
 };

 newlineBackwardHidden
 : {
  if (indentLock > 0){
   deleteIndent();
   indentLock -= 1;
   indentLvl -= 1;
 }
};

newlineBackward
:
{
  deleteIndent();
  indentThat();
  closeBraces();
  indentLvl -= 1;
  printf(NEWLINE_C);
};

maybeNewlineForward
: {
  if (indentLock == 0) {
    indentThat();
    addIndent();
    openBraces();
    printf(NEWLINE_C);    
    indentLvl += 1;
  }
  else {
    indentLock -= 1;
    deleteIndent();
    indentThat();
    addIndent();
    openBraces();
    printf(NEWLINE_C);
    beginLine();
  }
};

identifier
: IDENTIFIER { searchSymbol($1); }
;

string_literal
: STRING_LITERAL { printf ("<string>\n%s\n</string>\n", $1); }
;

sizeof
: SIZEOF { printf("%s\n", $1); }
;

alignas
: ALIGNAS { printf("%s\n", $1); }
;

static
: STATIC { printf("%s\n", $1); }
;

case
: CASE { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

default
: DEFAULT { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

if
  : IF { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

else
  : ELSE { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

switch
: SWITCH { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

while
  : WHILE { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

do
: DO { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

for
  : FOR { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

goto
: GOTO { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

continue
: CONTINUE { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

break 
: BREAK { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

return
: RETURN { printf("<keyword>\n%s\n</keyword>\n", $1); }
;

%%

void openBraces() {
  printf("<block>\n<braces>\n{\n</braces>\n<item>\n<block>\n");
  pushSymbolTable(symbolTable);
}

void closeBraces() {
  printf("</block>\n</item>\n}\n</block>\n");
  popSymbolTable(symbolTable);
}

void printType (char * type) 
{ 
  if (typeLock == false) { 
    free(typeName); 
    typeName = copy(type); 
  } 
  printf("<type>\n%s\n</type>\n", type); 
}

char * createDeclarationString(char * name)
{
  char * declaration = name;

  return declaration;  
}

void addNewSymbol(char * name) {

  TableObject to1;
  /* Check if a fonction has already been declared when we encounter its definition */
  if ((to1 = searchDeclarationFunctionSymbolTable(symbolTable, name, indentLvl)) != NULL) {
    char * declaration = to1->declaration;
    int  class = to1->class;
    printf("<declaration id=\"%d\" title=\"%s\" class=\"%d\">\n%s\n</declaration>\n", 
      uniqueId, declaration, class, name);
  }

  else {
    char * declaration = createDeclarationString(name);
    int class = uniqueId;

    TableObject to = createTableObject(name, class, declaration);
    addDeclarationTable(symbolTable, to, indentLvl);

    printf("<declaration id=\"%d\" title=\"%s\" class=\"%d\">\n%s\n</declaration>\n", 
      uniqueId++, declaration, class, name);

    //free(declaration);
  }
}

bool searchSymbol(char * name) {

  TableObject to = searchSymbolTable(symbolTable, name, indentLvl);

  if (to == NULL) {
    printf("<undefined id=\"%d\">\n%s\n</undefined>\n", 
      uniqueId++, name);
    return false;
  }

  else {
    char * declaration = to->declaration;
    int class = to->class;
    printf("<identifier id=\"%d\" title=\"%s\" class=\"%d\">\n%s\n</identifier>\n", 
      uniqueId++, declaration, class, name);
  }
  return true;
}

static int printBeginFile(int output) {
  int begin = open("assets/html/begin.html", O_RDONLY, 0444);
  char c;
  while(read(begin, &c, 1) > 0)
    printf("%c", c);
  return begin;
}

static int printEndFile(int output) {
  int end = open("assets/html/end.html", O_RDONLY, 0444);
  char c;
  while(read(end, &c, 1) > 0)
    printf("%c", c);
  return end;
}

int main()    
{
  symbolTable = createSymbolTable();
  functionParser = createFunctionParser();
  setDefaultRules(functionParser);

  int output = open("index.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);  
  int begin = printBeginFile(output);
  yyparse();
  int end = printEndFile(output);

  close(output);
  close(begin);
  close(end);

  free(typeName);
  destroySymbolTable(symbolTable);
  destroyFunctionParser(functionParser);

  return 0;    
}
