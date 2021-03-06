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


  #include <commun.h>
  #include <symbolTable.h>
  #include <functionParser.h>
  #include <util.h>

  extern int yylex();
  extern int yylex_destroy();

  void yyerror(char *);
  void openBraces();
  void closeBraces();
  void unlock();
  void endDeclaration();
  void atExitPrototype(char *);
  void atExitDefinition();
  void printType(char *);
  void addNewSymbol(char *);
  void refreshType(bool *);
  bool searchSymbol(char *);
  char * createClassString(char *);
  char * createDeclarationString(char *);
  void addType();

  /*
   *Typename = function name
   */
  char * typeName = NULL;
  bool typeLock = false;
  bool typeMustBeSave=false;
  bool declarationFunction = false;
  int indentLock = 0;
  int indentLvl = 0;
  int uniqueId = 1;
  char *saveLastIdentifier=NULL;
  char *saveLastIdentifierNotF=NULL;
  char *saveFunctionName=NULL;
  bool isFunction=false;
  int saveLastClass;
  TableObject saveLastFunction;
  TableObject saveLastVariable;
  bool typeIsStruct=false;

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
 %token <s> USER_TYPE
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
 : declaration_specifiers semi_colon  { endDeclaration(); }
 | declaration_specifiers init_declarator_list semi_colon { endDeclaration(); }
 | static_assert_declaration { endDeclaration(); }
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
 : TYPEDEF	      { printf("%s\n", $1);typeMustBeSave=true;} /* identifiers must be flagged as TYPEDEF_NAME */
 | EXTERN         { printf("%s\n", $1);typeMustBeSave=true; }
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
 | struct_or_union_specifier {}
 | enum_specifier
 | TYPEDEF_NAME	 { printType($1);}
 | USER_TYPE {  printType($1); }
 ;

 struct_or_union_specifier
 : struct_or_union maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 { typeIsStruct = true;addType(); }
| struct_or_union identifier maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
{ typeIsStruct = true;addType(); }
 | struct_or_union identifier
 { typeIsStruct = true;addType();}
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
 : IDENTIFIER { addNewSymbol($1); }
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
 | direct_declarator '(' { unlock(); } parameter_type_list ')' { atExitPrototype($<s>1); }
| direct_declarator '(' { unlock(); } ')' { atExitPrototype($<s>1); }
| direct_declarator '(' { unlock(); } identifier_list ')' { atExitPrototype($<s>1); }
 ;

 pointer
 : star type_qualifier_list pointer
 | star type_qualifier_list
 | star pointer
 | star
 ;

 star
 : '*' {
  //assert(typeName && "NULL typeName in rule star");
  if (typeName != NULL) {
    if (typeLock == false) {
      char * tmp = typeName;
      typeName = concat(typeName, "*");
      free(tmp);
    }
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
 : STATIC_ASSERT '(' constant_expression ',' string_literal ')' semi_colon
 { printf("%s\n", $1); }
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
 : function_definition
 | declaration
 ;

 function_definition
 : declaration_specifiers declarator  declaration_list compound_statement
 { atExitDefinition(saveFunctionName); }
 | declaration_specifiers declarator  compound_statement
 { atExitDefinition(saveFunctionName); }
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
: IDENTIFIER {
  free(saveLastIdentifier);
  saveLastIdentifier=copy($1);
  free(saveLastIdentifierNotF);
  saveLastIdentifierNotF=copy($1);
  searchSymbol($1);
};
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

void endDeclaration()
{
  assert(saveLastIdentifier != NULL);
  if (typeLock == false && !emptyFunctionParser(functionParser)) {
    parseVar(functionParser,saveLastIdentifier,fileName,uniqueId-1, saveLastVariable);
  }
 resetFunctionParser(functionParser);
 refreshType(&typeMustBeSave);
}

void unlock()
 {
  ++indentLvl;
  isFunction = true ;
  typeLock = true ;
  declarationFunction = true;
  pushSymbolTable(symbolTable);
}

void atExitPrototype(char * functionName)
{
  typeLock = false;
  isFunction = false;
  free(saveFunctionName);
  saveFunctionName=copy(functionName);
  parseFunction(functionParser, functionName, typeName, fileName, saveLastClass, saveLastFunction);
  resetFunctionParser(functionParser);
}

void refreshType(bool *a){
  if (*a == true){
    if (typeIsStruct) {
      char * element = concat("struct ",saveLastIdentifier);
      if (searchSymbolList(typeSymbolList,element) == NULL) {
        addSymbolList(typeSymbolList,element);
        // fprintf(stderr, "on add : %s\n", element);
  }
      else
        free(element);
    }
    else {
      if (searchSymbolList(typeSymbolList,saveLastIdentifier) == NULL) {
        addSymbolList(typeSymbolList,copy(saveLastIdentifier));
        // fprintf(stderr, "on add : %s\n", saveLastIdentifier);
      }
    }
    *a=false;
  }
  typeIsStruct=false;
}
/**
 * This function should only be called by struct definition/declaration
 */
void addType()
{
  if (typeIsStruct){
    if (searchSymbolList(typeSymbolList,saveLastIdentifier) == NULL) {
      char * element = concat("struct ",saveLastIdentifier);
      addSymbolList(typeSymbolList, element);
      // fprintf(stderr, "on add :%s\n", element);
    }
    typeIsStruct=false;
  }
  else {
    if (searchSymbolList(typeSymbolList,saveLastIdentifier) == NULL) {
      addSymbolList(typeSymbolList,  copy(saveLastIdentifier));
      // fprintf(stderr, "on add : %s\n", saveLastIdentifier);
    }
  }
}

void atExitDefinition()
{
  popSymbolTable(symbolTable);
  indentLvl -= 1;
  printf(NEWLINE_C);
}

void printType(char * type)
{
  if (typeLock == false) {
    //if (typeName != NULL)
      //fprintf(stderr,"REPLACE %s WITH %s",typeName,type);
    free(typeName);

    typeName = copy(type);
  }

  printf("<type>\n%s\n</type>\n", type);
}

/**
 * @brief Called when we encounted an identifier declaration, if it's a function (at indent level 0), we check if the function has already been declared, if not or if it's a variable or if the indent level is different than 0, we add the identifier in our symbolTable
 * @param name Our identifier name
 */
void addNewSymbol(char * name) {
  free(saveLastIdentifier);
  saveLastIdentifier = copy(name);

  TableObject to1;
  to1 = searchFunctionSymbolTable(symbolTable, name, indentLvl);
  /* Check if a fonction has already been declared when we encounter its definition */
  if (to1 != NULL) {
    int  class = to1->class;
    printf("<declaration class=\"%d\">\n%s\n</declaration>\n",
           class, name);
    if (indentLvl == 0) {
      saveLastClass = class;
      saveLastFunction = to1;
    }
    saveLastVariable = to1;
  }
  else {
    int class = uniqueId;

    TableObject to = createTableObject(name, class, NULL);
    addDeclarationTable(symbolTable, to, indentLvl);

    printf("<declaration class=\"%d\">\n%s\n</declaration>\n",
           class, name);

    if (indentLvl == 0) {
      saveLastClass = uniqueId;
      saveLastFunction = to;
    }
    saveLastVariable = to;
    uniqueId++;
  }
}

/**
 * @brief Called when we encounter a variable, search for an already declared identifier with the same name at the proper indentation levels, if we found one, the variable is given the same class
 * @param  name identifier name
 * @return      true if element found
 */
bool searchSymbol(char * name) {

  TableObject to = searchSymbolTable(symbolTable, name, indentLvl);

  if (to == NULL) {
    printf("<undefined>\n%s\n</undefined>\n", name);
    return false;
  }
  else {
    int class = to->class;
    printf("<identifier class=\"%d\">\n%s\n</identifier>\n",
      class, name);
    printDocumentation(functionParser,name,"",class,to);

  }
  return true;
}

/**
 * @brief Change yyparse input
 * @param file Where to read C code
 */
static void parseFile(char * file)
{
  int fd = open(file, O_RDONLY, 0444);
  dup2(fd, 0);
  close(fd);
  yyparse();
}

/**
 * @brief Create html index file
 * @param fileArray Array of all our files
 */
static void createIndexFile(char ** fileArray, int size)
{
  FILE *f = fopen("output/index.html", "w");
  appendFile(f, "assets/html/begin.html");
  appendSidebar(f, fileArray, size, "index", true);
  appendFile(f, "assets/html/end.html");
  fclose(f);
}

/**
 * @param  argc Number of files to be parsed
 * @param  argv Array of all our files
 */
int main(int argc, char *argv[])
{
  if (argc < 2) {
    fprintf(stderr, "Usage : %s file1.h ... fileN.h file1.c ... fileN.c\n", argv[0]);
    return -1;
  }

 // push initial list
  symbolTable = createSymbolTable();
  pushSymbolTable(symbolTable);
  typeSymbolList = createSymbolList(compareChar,destroyChar);


  functionParser = createFunctionParser();
  setDefaultRules(functionParser);

  createIndexFile(argv+1, argc-1);

  int output;

  int i;
  char *html=".html";
  char *doc=".doc.html";
  char *fullFileName;
  char *docFileName ;

  for (i = 1; i < argc; ++i)
  {
    fullFileName = concat(argv[i], html);
    docFileName = concat(argv[i], doc);
    fileName=argv[i];

    output = open(fullFileName,O_WRONLY|O_TRUNC|O_CREAT,0666);

    dup2(output, 1);
    close(output);

    appendFile(stdout, "assets/html/begin.html");
    appendSidebar(stdout, argv+1, argc-1, fileName, true);
    fprintf(stdout, "<div id=\"outer\" class=\"code\">");
    appendBeginDoc(docFileName, argv+1, argc-1, fileName);
    parseFile(argv[i]);
    appendEndDoc(docFileName);
    fprintf(stdout, "</div>");
    appendFile(stdout, "assets/html/end.html");

    fflush(NULL);

    free(fullFileName);
    fullFileName = NULL;
    free(docFileName);
    docFileName = NULL;

    free(saveFunctionName);
    saveFunctionName = NULL;
    free(saveLastIdentifier);
    saveLastIdentifier = NULL;
    free(saveLastIdentifierNotF);
    saveLastIdentifierNotF = NULL;
    free(typeName);
    typeName = NULL;

    yylex_destroy();
  }

  destroySymbolTable(symbolTable);
  destroySymbolList(typeSymbolList);
  destroyFunctionParser(functionParser);

  return 0;
}
