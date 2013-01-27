%{
	#include <stdio.h>
	#include <stdlib.h>
	
	extern char* yytext;	
	extern int yylineno; 
	int yyerror(char *);

%}

/* defintions: token, precedence, types etc. */

%union {
	double	double_val;
	int	int_val;
	char*	str_ptr;
}

// terminal token declaration
%token ASSIGN VAR BEGINSYM END
%token IF THEN ELSE ENDIF
%token WHILE DO ENDWHILE
%token REPEAT UNTIL ENDREPEAT
%token FOR TO ENDFOR PARFOR ENDPARFOR
%token PRIVATE REDUCE
%token PROC ENDPROC PARPROC ENDPARPROC
%token READ WRITE
%token IN OUT INOUT REF
%token AND OR
%token EQ NEQ LT GT LTE GTE

// type information for terminal tokens: identifiers and numbers
%token<double_val> INT REAL
%token<str_ptr> IDENTIFIER


// associativity and precedence of operators
%left GTE LTE EQ NEQ GT LT
%left '+' '-'
%left '*' '/'
%left "DIV" "MOD"
%nonassoc UMINUS NOT

%%

/* rules 
 * For EBNF -> BNF rules: http://lampwww.epfl.ch/teaching/archive/compilation-ssc/2000/part4/parsing/node3.html
 */

program: 		block END
			;
variable:		IDENTIFIER				{}
			;
block:			declarationsOption BEGINSYM statementGroup END
			;
statementGroup:		|
			statementGroup statement 
			;
declarationsOption:	|
			declarations 
			;
declarations:		VAR varListGroup
			;
varListGroup:		|
			varListGroup varList ':' type ';'
			;
varList: 		variable variableGroup
			;
variableGroup:		|
			variableGroup ',' variable 
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
			;
assignment:		variable ASSIGN expression
			| variable '[' expression ']' ASSIGN expression
			;
expression:		variable
			| variable '[' expression ']' 
			| signOption INT
			| signOption REAL
			| expression arithmetricOp expression
			| INT '(' expression ')'
			| sign expression
			;
signOption:		sign
			|
			;
sign:			'+'
			| '-'
			;
arithmetricOp:		'*'
			| '/'
			| '+'
			| '-'
			;
comparisonOp:		EQ				{}
			| NEQ				{}
			| LT				{}
			| GT				{}
			| LTE				{}
			| GTE				{}
			;
comparison:		expression comparisonOp expression
			| comparison logicOp comparison
			| NOT comparison
			;
logicOp:		AND				{}
			| OR				{}
			;
test:			IF comparison THEN statementGroup elseOption ENDIF
			;
elseOption:		|
			ELSE statementGroup
			;
loop:			WHILE comparison DO statementGroup ENDWHILE
			| REPEAT statementGroup UNTIL comparison ENDREPEAT
			| FOR variable ASSIGN expression TO expression DO statementGroup ENDFOR
			| PARFOR variable ASSIGN expression TO expression parMod DO statementGroup ENDPARFOR
			;
parMod:			privateVarListOption reduceGroup
			;
privateVarListOption:	|
			PRIVATE varList
			;
reduceGroup:		|
			reduceGroup REDUCE reduceOp varList
			;
reduceOp:		'+'				{}
			|'-'				{}
			|"MIN"				{}
			|"MAX"				{}
			;
input:			READ '(' variable ')'
			;
output:			WRITE '(' expression ')'
			;
procedure:		PROC procName '(' parametersOption ')' block ENDPROC
			| PARPROC procName '(' parametersOption ')' block ENDPARPROC
			;
procName:		IDENTIFIER				{}
			;
parameters:		parameter parameterGroup
			;
parametersOption:	|
			parameters
			;
parameterGroup:		|
			parameterGroup ',' parameter 
			;
parameter:		passBy variable ':' type
			;
passBy:			IN
			| OUT
			| INOUT
			| REF
			;
procCall:		variable '(' arguments ')'
			;
arguments:		expression expressionGroup
			;
expressionGroup:	|
			expressionGroup ',' expression 
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
 */
int yyerror(char *err) {
  fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

