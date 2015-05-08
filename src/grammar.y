%{

  #include <string.h>
  #include <assert.h>
  #include <stdio.h>
  #include <stdbool.h>
  #include <math.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <unistd.h>


  #include "commun/commun.h"
  #include "symbolTable/symbolTable.h"
  #include "functionParser.h"
  #include "util/util.h"

  extern int yylex();
  extern int yylex_destroy();

  void yyerror(char *);
  void openBraces();
  void closeBraces();
  void atExitDeclaration(char *);
  void atExitDefinition();
  void printType(char *);
  void addNewSymbol(char *);
  bool searchSymbol(char *);
  char * createClassString(char *);
  char * createDeclarationString(char *);
  void addType();

  /*
   *Typename = function name
   */
  char * typeName = NULL;
  char *filename;
  bool typeLock = false;
  bool declarationFunction = false;
  int indentLock = 0;
  int indentLvl = 0;
  int uniqueId = 1;
  char *saveLastIdentifier=NULL;

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
 | star
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
 | multiplicative_expression star cast_expression
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
 : declaration_specifiers semi_colon
 | declaration_specifiers init_declarator_list semi_colon
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
 | atomic_type_specifier
 | struct_or_union_specifier
 | enum_specifier
 | TYPEDEF_NAME	 { printType($1); }
 ;

 struct_or_union_specifier
 : struct_or_union maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 | struct_or_union identifier maybeNewlineForward '{' struct_declaration_list newlineBackward '}' {addType();}
 | struct_or_union identifier {addType();}
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
 : specifier_qualifier_list semi_colon	/* for anonymous struct/union */
 | specifier_qualifier_list struct_declarator_list semi_colon
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
 : IDENTIFIER { addNewSymbol($1);}
 | '(' declarator ')'
 | direct_declarator '[' ']'
 | direct_declarator '[' star ']'
 | direct_declarator '[' static type_qualifier_list assignment_expression ']'
 | direct_declarator '[' static assignment_expression ']'
 | direct_declarator '[' type_qualifier_list star ']'
 | direct_declarator '[' type_qualifier_list static assignment_expression ']'
 | direct_declarator '[' type_qualifier_list assignment_expression ']'
 | direct_declarator '[' type_qualifier_list ']'
 | direct_declarator '[' assignment_expression ']'
 | direct_declarator '(' { ++indentLvl; typeLock = true ; declarationFunction = true; pushSymbolTable(symbolTable); } parameter_type_list ')' { atExitDeclaration($<s>1); }
| direct_declarator '(' { ++indentLvl; typeLock = true; declarationFunction = true; pushSymbolTable(symbolTable); } ')' { atExitDeclaration($<s>1); }
| direct_declarator '(' { ++indentLvl; typeLock = true; declarationFunction = true; pushSymbolTable(symbolTable); } identifier_list ')' { atExitDeclaration($<s>1); }
 ;

 pointer
 : star type_qualifier_list pointer
 | star type_qualifier_list
 | star pointer
 | star
 ;


 star
 : '*' {
  assert(typeName && "NULL typeName in rule star");
  if (typeLock == false) {
    char * tmp = typeName;
    typeName = concat(typeName, "*");
    free(tmp);
  }
  printf("*");
};

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
 | '[' star ']'
 | '[' static type_qualifier_list assignment_expression ']'
 | '[' static assignment_expression ']'
 | '[' type_qualifier_list static assignment_expression ']'
 | '[' type_qualifier_list assignment_expression ']'
 | '[' type_qualifier_list ']'
 | '[' assignment_expression ']'
 | direct_abstract_declarator '[' ']'
 | direct_abstract_declarator '[' star ']'
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
 : STATIC_ASSERT '(' constant_expression ',' string_literal ')' semi_colon { printf("%s\n", $1); }
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
 : semi_colon
 | expression semi_colon
 ;


 selection_statement
 : if '(' expression ')' newlineForward statement newlineBackwardHidden else  newlineForward statement newlineBackwardHidden
 | if '(' expression ')' newlineForward statement newlineBackwardHidden
 | switch '(' expression ')' newlineForward statement newlineBackwardHidden
 ;

 iteration_statement
 : while '(' expression ')' newlineForward statement newlineBackwardHidden
 | do newlineForward statement while '(' expression ')' semi_colon
 | for '(' expression_statement expression_statement ')' newlineForward statement newlineBackwardHidden
 | for '(' expression_statement expression_statement expression ')' newlineForward statement newlineBackwardHidden
 | for '(' declaration expression_statement ')' newlineForward statement newlineBackwardHidden
 | for '(' declaration expression_statement expression ')' newlineForward statement newlineBackwardHidden
 ;

 jump_statement
 : goto identifier semi_colon
 | continue semi_colon
 | break semi_colon
 | return semi_colon
 | return expression semi_colon
 ;

 translation_unit
 : external_declaration
 | translation_unit external_declaration
 ;

 external_declaration
 : function_definition { atExitDefinition(); }
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
    beginLine(); // lex function
  }
};

semi_colon
: ';' {
  if (declarationFunction == true) {
    declarationFunction = false;
    popSymbolTable(symbolTable);
    --indentLvl;
  }
  if (indentLvl == 0)
    printf(NEWLINE_C);
};

identifier
: IDENTIFIER { searchSymbol($1);free(saveLastIdentifier);saveLastIdentifier=copy($1);}
;
string_literal
: STRING_LITERAL {
  printf ("<string>\n%s\n</string>\n", $1);
  free($1);
};

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
  declarationFunction = false;
  printf("<block>\n<braces>\n{\n</braces>\n<item>\n<block>\n");
  pushSymbolTable(symbolTable);
}

void closeBraces() {
  printf("</block>\n</item>\n}\n</block>\n");
  popSymbolTable(symbolTable);
}

void atExitDeclaration (char * functionName) {
  typeLock = false;

  //printf("<declaration title=\"");
  parseFunction(functionParser, functionName, typeName, filename);
  //printf("\">yolosweg</declaration>");

  resetFunctionParser(functionParser);
  //printf(NEWLINE_C);
}
void addType()
{

  addSymbolList(typeSymbolList,copy(saveLastIdentifier));

}
void atExitDefinition()
{
  popSymbolTable(symbolTable);
  indentLvl -= 1;
  printf(NEWLINE_C);
}

void printType (char * type)
{
  if (typeLock == false) {
    free(typeName);
    typeName = copy(type);
  }
  fprintf(stderr,"LAST TYPE %s",type);
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
    printf("<declaration title=\"%s\" class=\"%d\">\n%s\n</declaration>\n",
      declaration, class, name);
  }
  else {
    char * declaration = createDeclarationString(name);
    int class = uniqueId;

    TableObject to = createTableObject(name, class, declaration);
    addDeclarationTable(symbolTable, to, indentLvl);

    printf("<declaration title=\"%s\" class=\"%d\">\n%s\n</declaration>\n",
      declaration, class, name);

    uniqueId++;
    //free(declaration);
  }
}

bool searchSymbol(char * name) {

  TableObject to = searchSymbolTable(symbolTable, name, indentLvl);

  if (to == NULL) {
    printf("<undefined>\n%s\n</undefined>\n", name);
    return false;
  }
  else {
    char * declaration = to->declaration;
    int class = to->class;
    printf("<identifier title=\"%s\" class=\"%d\">\n%s\n</identifier>\n",
      declaration, class, name);
  }
  return true;
}

/**
 * change yyparse input
 * @param file Where to read C or Latex code
 */
static void parseFile(char * file)
{
  int fd = open(file, O_RDONLY, 0444);
  dup2(fd, 0);
  close(fd);
  yyparse();

}

// static int openOutputFile (char * dest) {
//   char * s = "output/";
//   char buf [strlen(dest)+strlen(s)+1];
//   strcpy(buf, s);
//   strcat(buf, dest);
//   return open(buf,O_WRONLY|O_TRUNC|O_CREAT,0666);
// }

int main(int argc, char *argv[])
{
  if (argc < 2 || argc > 3){
    fprintf(stderr, "Usage : %s src_file.c output_name.html\n", argv[0]);
    return -1;
  }

 // push initial list
  functionParser = createFunctionParser();
  setDefaultRules(functionParser);

  int output;

  int i;
  char *html=".html";
  char *doc=".doc.html";
  char *fullfilename;
  char *docfilename;

  for (i = 1 ; i < argc ; ++i)
    {
      typeSymbolList = createSymbolList(compareChar,destroyChar);
      symbolTable = createSymbolTable();
      pushSymbolTable(symbolTable);
      fullfilename=concat(argv[i],html);
      filename=argv[i];
      docfilename=concat(filename, doc);
      output = open(fullfilename,O_WRONLY|O_TRUNC|O_CREAT,0666);

      dup2(output, 1);
      close(output);

      appendFile("assets/html/begin.html");
      appendBeginDoc(docfilename);
      parseFile(argv[i]);
      appendEndDoc(docfilename);
      appendFile("assets/html/end.html");

      fflush(NULL);
      close(1);

      destroySymbolTable(symbolTable);
      destroySymbolList(typeSymbolList);
      free(typeName);
      free(docfilename);
      free(fullfilename);
      free(saveLastIdentifier);
      typeName = NULL;

    }



  destroyFunctionParser(functionParser);

  yylex_destroy();

  return 0;
}
