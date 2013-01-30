%{
	#include <stdio.h>
	#include <stdlib.h>
	
	extern char* yytext;	
	extern int yylineno; 
	int yyerror(char *);
%}

/* defintions: token, precedence, types etc. */

%start program

%union {
	double	double_val;
	int	int_val;
	char*	str_ptr;
}

// terminal token declaration
%token ASSIGN VAR BEGINSYM END
%token THEN ENDIF
%token WHILE DO ENDWHILE
%token REPEAT UNTIL ENDREPEAT
%token FOR TO ENDFOR PARFOR ENDPARFOR
%token PRIVATE REDUCE
%token PROC ENDPROC PARPROC ENDPARPROC
%token READ WRITE
%token IN OUT INOUT REF
%token INT REAL
%token MIN MAX
%token LPAREN RPAREN
%token END_OF_FILE 

// type information for terminal tokens: identifiers and numbers
%token<double_val> NUMBER
%token<str_ptr> IDENTIFIER

// associativity and precedence of operators
%right ASSIGN
%left AND
%left OR
%left NOT
%left GTE LTE EQ NEQ GT LT
%left '-' '+' 
%left '*' '/'
%left DIV MOD
%left USIGN
%nonassoc IF
%nonassoc ELSE

%%

/* rules 
 * For EBNF -> BNF rules: http://lampwww.epfl.ch/teaching/archive/compilation-ssc/2000/part4/parsing/node3.html
 */

program: 		block END_OF_FILE			{exit(0);}
			;
variable:		IDENTIFIER				{}
			;
block:			declarations BEGINSYM statementGroup END
			| BEGINSYM statementGroup END
			;
statementGroup:		statementGroup statement
			| 
			;
declarations:		VAR varListGroup
			;
varListGroup:		varListGroup varList ':' type ';'
			|
			;
varList: 		variable variableGroup
			;
variableGroup:		variableGroup ',' variable
			| 
			;
type:			basicType 
			| arrayType
			;
arrayType:		basicType '[' expression ']'
			;
basicType:		INT				{}
			| REAL				{}
			;
statement:		assignment ';' 
			| block ';' 
			| test ';' 
			| loop ';' 
			| input ';' 
			| output ';' 
			| procedure ';' 
			| procCall ';'
			| error ';'
			;
assignment:		variable ASSIGN expression
			| variable '[' expression ']' ASSIGN expression
			;
expression:		variable
			| variable '[' expression ']' 
			| NUMBER
			| '+' expression %prec USIGN
			| '-' expression %prec USIGN	{/*printf("uminus rule triggered at %d.\n", yylineno);*/}
			| expression DIV expression
			| expression MOD expression
			| expression '/' expression
			| expression '*' expression
			| expression '+' expression	{/*printf("expr+expr rule triggered at %d.\n", yylineno);*/}
			| expression '-' expression	{/*printf("expr-expr rule triggered at %d.\n", yylineno);*/}
			| INT LPAREN expression RPAREN
			;
comparisonOp:		EQ				{}
			| NEQ				{}
			| LT				{}
			| GT				{}
			| LTE				{}
			| GTE				{}
			;
comparison:		expression comparisonOp expression
			| comparison AND comparison
			| comparison OR comparison
			| NOT comparison
			;
test:			IF comparison THEN statementGroup ENDIF
			| IF comparison THEN statementGroup ELSE statementGroup ENDIF
			;
loop:			WHILE comparison DO statementGroup ENDWHILE
			| REPEAT statementGroup UNTIL comparison ENDREPEAT
			| FOR variable ASSIGN expression TO expression DO statementGroup ENDFOR
			| PARFOR variable ASSIGN expression TO expression parMod DO statementGroup ENDPARFOR
			;
parMod:			reduceGroup
			| PRIVATE varList reduceGroup
			;
reduceGroup:		reduceGroup REDUCE reduceOp varList
			|
			;
reduceOp:		'-'				{/*printf("-reduceop rule triggered at %d.\n", yylineno);*/}
			|'+'				{}
			| MIN				{}
			| MAX				{}
			;
input:			READ LPAREN variable RPAREN
			;
output:			WRITE LPAREN expression RPAREN
			;
procedure:		PROC procName LPAREN parametersOption RPAREN block ENDPROC
			| PARPROC procName LPAREN parametersOption RPAREN block ENDPARPROC
			;
procName:		IDENTIFIER				{}
			;
parameters:		parameter parameterGroup
			;
parametersOption:	parameters
			|
			;
parameterGroup:		parameterGroup ',' parameter
			| 
			;
parameter:		passBy variable ':' type
			;
passBy:			IN
			| OUT
			| INOUT
			| REF
			;
procCall:		variable LPAREN arguments RPAREN
			;
arguments:		expression expressionGroup
			|					/* added epsilon alternative not in EBNF spec */
			;
expressionGroup:	expressionGroup ',' expression
			| 
			;

%%

/* subroutines */
#include "pseudo.yy.c"

int main(int argc,char *argv[]) {
  char *result;
  result = (char *)yyparse();
  return(1);
}

/*
 * yyerror - returns error msg "err" and line number
 * also see http://oreilly.com/linux/excerpts/9780596155971/error-reporting-recovery.html
 */
int yyerror(char *err) {
  fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

