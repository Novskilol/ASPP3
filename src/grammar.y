%{		
    #include <sys/types.h>		
    #include <sys/stat.h>
    #include <string.h>
    #include <fcntl.h>		
    #include <stdio.h>
    #include "foo.h"
    #include "commun.h"
    #include <stdbool.h>

    int currentName = 0;
    void addnames(char *name);

    int indentToBeRemoved;
    int indentLocked=0;
    void yyerror(char*s);

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
   %token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
   %token	COMPLEX IMAGINARY 
   %token	STRUCT UNION ENUM ELLIPSIS

   %token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

   %token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

   %start translation_unit
   %%

   primary_expression
   : IDENTIFIER
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
   : IDENTIFIER
   ;

   string
   : STRING_LITERAL
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
   | DEFAULT ':' assignment_expression
   ;

   postfix_expression
   : primary_expression
   | postfix_expression '[' expression ']'
   | postfix_expression '(' ')'
   | postfix_expression '(' argument_expression_list ')'
   | postfix_expression '.' IDENTIFIER
   | postfix_expression PTR_OP IDENTIFIER
   | postfix_expression INC_OP
   | postfix_expression DEC_OP
   | '(' type_name ')' maybenewlineforward '{' initializer_list newlinebackward '}'
   | '(' type_name ')' maybenewlineforward '{' initializer_list ',' newlinebackward '}'
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
   : VOID
   | CHAR
   | SHORT
   | INT
   | LONG
   | FLOAT
   | DOUBLE
   | SIGNED
   | UNSIGNED
   | BOOL
   | COMPLEX
   | IMAGINARY	  	/* non-mandated extension */
   | atomic_type_specifier
   | struct_or_union_specifier
   | enum_specifier
   | TYPEDEF_NAME		/* after it has been defined as such */
   ;

   struct_or_union_specifier
   : struct_or_union maybenewlineforward '{' struct_declaration_list newlinebackward '}'
   | struct_or_union IDENTIFIER maybenewlineforward '{' struct_declaration_list newlinebackward '}'
   | struct_or_union IDENTIFIER
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
   : ENUM maybenewlineforward '{' enumerator_list newlinebackward '}'
   | ENUM maybenewlineforward '{' enumerator_list ',' newlinebackward '}'
   | ENUM IDENTIFIER maybenewlineforward '{' enumerator_list newlinebackward '}'
   | ENUM IDENTIFIER maybenewlineforward '{' enumerator_list ',' newlinebackward '}'
   | ENUM IDENTIFIER
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
   : IDENTIFIER
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
   : IDENTIFIER
   | identifier_list ',' IDENTIFIER
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
   : maybenewlineforward '{' initializer_list newlinebackward '}'
   | maybenewlineforward '{' initializer_list ',' newlinebackward '}'
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
   | '.' IDENTIFIER
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
   : IDENTIFIER ':' statement
   | CASE constant_expression ':' newlineforward statement newlinebackwardhidden
   | DEFAULT ':' statement
   ;

   compound_statement
   : maybenewlineforward '{' newlinebackward '}'
   | maybenewlineforward '{'  block_item_list newlinebackward '}'
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
   : IF '(' expression ')' newlineforward statement newlinebackward ELSE  newlineforward statement newlinebackwardhidden
   | IF '(' expression ')' newlineforward statement newlinebackwardhidden
   | SWITCH '(' expression ')' newlineforward statement newlinebackwardhidden
   ;

   iteration_statement
   : WHILE '(' expression ')' newlineforward statement newlinebackwardhidden
   | DO newlineforward statement WHILE '(' expression ')' ';'
   | FOR '(' expression_statement expression_statement ')' newlineforward statement newlinebackwardhidden
   | FOR '(' expression_statement expression_statement expression ')' newlineforward statement newlinebackwardhidden
   | FOR '(' declaration expression_statement ')' newlineforward statement newlinebackwardhidden
   | FOR '(' declaration expression_statement expression ')' newlineforward statement newlinebackwardhidden
   ;

   jump_statement
   : GOTO IDENTIFIER ';'
   | CONTINUE ';'
   | BREAK ';'
   | RETURN ';'
   | RETURN expression ';'
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
   : declaration_specifiers declarator declaration_list compound_statement
   | declaration_specifiers declarator compound_statement
   ;

   declaration_list
   : declaration
   | declaration_list declaration
   ;

   newlineforward: {
       addIndent();
       printf(C_NEWLINE);
       indentLocked+=1;

   };
   newlinebackwardhidden:{
      if (indentLocked>0){
       deleteIndent();
       indentLocked-=1;
   }

};
newlinebackward:{
  deleteIndent();
  

  indentThat();
  printf("}");

  printf(C_NEWLINE);


};
maybenewlineforward:
{
  if(indentLocked == 0 ){
    indentThat();
    addIndent();
    printf("{");
    printf(C_NEWLINE);
    
    

}
else{
    indentLocked-=1;
    // fprintf(stderr,"jump");
    deleteIndent();
    indentThat();
    addIndent();
    printf("{");
    printf(C_NEWLINE);
    beginLigne();
}



};

%%

void addnames(char *name){
 namesdef[currentName]=name;
 currentName++;
}

printBeginFile(int output) {
  int begin = open("html/begin.html", O_RDONLY, 0444);
  char c;
  while(read(begin, &c, 1) > 0)
  printf("%c", c);
  close(begin);
}

printEndFile(int output) {
  int end = open("html/end.html", O_RDONLY, 0444);
  char c;
  while(read(end, &c, 1) > 0)
  printf("%c", c);
  close(end);
}

int main()    
{
  indentLocked = 0;
  indentToBeRemoved=0;

  int output = open("index.html",O_WRONLY|O_TRUNC|O_CREAT,0666);    
  dup2(output, 1);
  
  printBeginFile(output);

  yyparse();

  printEndFile(output);

  close(output);

  int fdl = open("lexAfter.l",O_WRONLY|O_TRUNC|O_CREAT,0666);
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
 write(fdl,"\n",strlen("\n"));

 return 0;    
}