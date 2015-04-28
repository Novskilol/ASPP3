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
  #include "symboleTable/symboleTable.h"
  
  extern int yylex();

  //void addnames(char *name); 
  void yyerror(char*s);
  void open_braces();
  void close_braces();
  void add_new_symbole(char *);
  void search_symbole(char *);
  //char * create_class_string(char *);

  int indentLocked = 0;
  int indentLvl = 0;
  int uniqueId = 1;

  %}

  %union{
   char *s;
 }

 %token <s> IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL FUNC_NAME SIZEOF
 %token	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
 %token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
 %token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
 %token	XOR_ASSIGN OR_ASSIGN
 %token	TYPEDEF_NAME ENUMERATION_CONSTANT

 %token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
 %token	CONST RESTRICT VOLATILE
 %token	<s> BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
 %token	<s> COMPLEX IMAGINARY 
 %token	STRUCT UNION ENUM ELLIPSIS

 %token	<s> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

 %token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

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
 : I_CONSTANT		/* includes character_constant */
 | F_CONSTANT
 | ENUMERATION_CONSTANT	/* after it has been defined as such */
 ;

 enumeration_constant		/* before it has been defined as such */
 : identifier
 ;

 string
 : string_literal
 | FUNC_NAME
 ;

 generic_selection
 : GENERIC '(' assignment_expression ',' generic_assoc_list ')'
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
 | SIZEOF unary_expression
 | SIZEOF '(' type_name ')'
 | ALIGNOF '(' type_name ')'
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
 : TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
 | EXTERN
 | STATIC
 | THREAD_LOCAL
 | AUTO
 | REGISTER
 ;

 type_specifier
 : VOID       { printf("\n<type>\n%s\n</type>", $1); }
 | CHAR       { printf("\n<type>\n%s\n</type>", $1); }
 | SHORT      { printf("\n<type>\n%s\n</type>", $1); }
 | INT        { printf("\n<type>\n%s\n</type>", $1); }
 | LONG       { printf("\n<type>\n%s\n</type>", $1); }
 | FLOAT      { printf("\n<type>\n%s\n</type>", $1); }
 | DOUBLE     { printf("\n<type>\n%s\n</type>", $1); }
 | SIGNED     { printf("\n<type>\n%s\n</type>", $1); }
 | UNSIGNED   { printf("\n<type>\n%s\n</type>", $1); }
 | BOOL       { printf("\n<type>\n%s\n</type>", $1); }
 | COMPLEX    { printf("\n<type>\n%s\n</type>", $1); }
 | IMAGINARY  { printf("\n<type>\n%s\n</type>", $1); }
 | atomic_type_specifier    
 | struct_or_union_specifier
 | enum_specifier           
 | TYPEDEF_NAME		          
 ;

 struct_or_union_specifier
 : struct_or_union maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 | struct_or_union identifier maybeNewlineForward '{' struct_declaration_list newlineBackward '}'
 | struct_or_union identifier
 ;

 struct_or_union
 : STRUCT
 | UNION
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
 : ENUM maybeNewlineForward '{' enumerator_list newlineBackward '}'
 | ENUM maybeNewlineForward '{' enumerator_list ',' newlineBackward '}'
 | ENUM identifier maybeNewlineForward '{' enumerator_list newlineBackward '}'
 | ENUM identifier maybeNewlineForward '{' enumerator_list ',' newlineBackward '}'
 | ENUM identifier
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
 : ATOMIC '(' type_name ')'
 ;

 type_qualifier
 : CONST
 | RESTRICT
 | VOLATILE
 | ATOMIC
 ;

 function_specifier
 : INLINE
 | NORETURN
 ;

 alignment_specifier
 : ALIGNAS '(' type_name ')'
 | ALIGNAS '(' constant_expression ')'
 ;

 declarator
 : pointer direct_declarator
 | direct_declarator
 ;

 direct_declarator
 : IDENTIFIER { add_new_symbole($1); }
 | '(' declarator ')'
 | direct_declarator '[' ']'
 | direct_declarator '[' '*' ']'
 | direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
 | direct_declarator '[' STATIC assignment_expression ']'
 | direct_declarator '[' type_qualifier_list '*' ']'
 | direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
 | direct_declarator '[' type_qualifier_list assignment_expression ']'
 | direct_declarator '[' type_qualifier_list ']'
 | direct_declarator '[' assignment_expression ']'
 | direct_declarator '(' parameter_type_list ')' 
 | direct_declarator '(' ')' 
 | direct_declarator '(' identifier_list ')' 
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
 | '[' STATIC type_qualifier_list assignment_expression ']'
 | '[' STATIC assignment_expression ']'
 | '[' type_qualifier_list STATIC assignment_expression ']'
 | '[' type_qualifier_list assignment_expression ']'
 | '[' type_qualifier_list ']'
 | '[' assignment_expression ']'
 | direct_abstract_declarator '[' ']'
 | direct_abstract_declarator '[' '*' ']'
 | direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
 | direct_abstract_declarator '[' STATIC assignment_expression ']'
 | direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
 | direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
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
 : STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'
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
 : if '(' expression ')' newlineForward statement newlineBackward else  newlineForward statement newlineBackwardHidden
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
   indentLocked += 1;
   indentLvl += 1;
 };

 newlineBackwardHidden
 : {
  if (indentLocked > 0){
   deleteIndent();
   indentLocked -= 1;
   indentLvl -= 1;
 }
};

newlineBackward
:
{
  deleteIndent();
  indentThat();
  close_braces();
  indentLvl -= 1;
  printf(NEWLINE_C);
};

maybeNewlineForward
: {
  if (indentLocked == 0) {
    indentThat();
    addIndent();
    open_braces();
    printf(NEWLINE_C);    
    indentLvl += 1;
  }
  else {
    indentLocked -= 1;
    deleteIndent();
    indentThat();
    addIndent();
    open_braces();
    printf(NEWLINE_C);
    beginLine();
  }
};

identifier
: IDENTIFIER { search_symbole($1); }
;

string_literal
: STRING_LITERAL { printf ("\n<string>\n%s<\n</string>", $1); }
;

case
: CASE { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

default
: DEFAULT { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

if
: IF { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

else
: ELSE { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

switch
: SWITCH { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

while
: WHILE { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

do
: DO { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

for
: FOR { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

goto
: GOTO { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

continue
: CONTINUE { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

break 
: BREAK { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

return
: RETURN { printf("\n<keyword>\n%s\n</keyword>", $1); }
;

%%

void open_braces() {
  printf("\n<block>\n<braces>\n{\n</braces>\n<item>\n<block>");
}

void close_braces() {
  printf("\n</block>\n</item>\n}\n</block>");
}

char * create_class_string(char * name) 
{
 int buf_size = (int)((ceil(log10(uniqueId))+1) * sizeof(char));
 char id_str[buf_size];
 sprintf(id_str, "%d", uniqueId);
 
 int class_size = strlen(id_str) + 1;
 
 char * class_str = malloc(sizeof(*class_str) * class_size);
 strcpy(class_str, id_str);
 
 return class_str;
}

char * create_declaration_string(char * name)
{
  char * declaration = name;

  return declaration;  
}

void add_new_symbole(char * name) {
  char * declaration = create_declaration_string(name);
  char * class = create_class_string(name);

  TableObject to = createTableObject(name, class, declaration);
  addDeclarationTable(symbol_table, to, indentLvl);

  printf("\n<declaration id=\"%d\" title=\"%s\" class=\"%s\">\n%s\n</declaration>", 
    uniqueId++, declaration, class, name);

  free(class);
  //free(declaration);
}

void search_symbole(char * name) {

  TableObject to = searchSymboleTable(symbol_table, name, indentLvl);

  if (to == NULL) {
    printf("\n<identifier id=\"%d\">\n%s\n</identifier>", 
      uniqueId++, name);
  }

  else {
    char * declaration = to->declaration;
    char * class = to->class;
    printf("\n<identifier id=\"%d\" title=\"%s\" class=\"%s\">\n%s\n</identifier>", 
      uniqueId++, declaration, class, name);
  }
}

/*void addnames(char *name) { 
 namesdef[currentName]=name;
 currentName++;
 }*/

 static int printBeginFile(int output) {
  int begin = open("html/begin.html", O_RDONLY, 0444);
  char c;
  while(read(begin, &c, 1) > 0)
  printf("%c", c);
  return begin;
}

static int printEndFile(int output) {
  int end = open("html/end.html", O_RDONLY, 0444);
  char c;
  while(read(end, &c, 1) > 0)
  printf("%c", c);
  return end;
}

int main()    
{
  symbol_table = createSymboleTable();

  int output = open("index.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);
  
  int begin = printBeginFile(output);

  yyparse();

  int end = printEndFile(output);

  close(output);
  close(begin);
  close(end);

  destroySymboleTable(symbol_table);

  /*int fdl = open("lexAfter.l",O_WRONLY|O_TRUNC|O_CREAT,0666);
  char *lex="%{\n#include \"foo.h\"\n%}\n%%\n";
  write(fdl,lex,strlen(lex));
  int j=0;
  while(namesdef[j]!=NULL)
  {
   write(fdl,"\n",strlen("\n"));
   write(fdl,"\"",strlen("\""));
   write(fdl,namesdef[j],strlen(namesdef[j]));
   write(fdl,"\"",strlen("\""));
   lex=" {printf(\"<script>\");ECHO;printf(\"</script>\");}";
   write(fdl,lex,strlen(lex));
   j++;
  }
  write(fdl,"\n",strlen("\n"));*/

  return 0;    
}
