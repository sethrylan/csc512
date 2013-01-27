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
%token END_OF_FILE 

// type information for terminal tokens: identifiers and numbers
%token<double_val> NUMBER
%token<str_ptr> IDENTIFIER

// associativity and precedence of operators
%right ASSIGN
%left GTE LTE EQ NEQ GT LT
%left '+' '-' 
%left '*' '/'
%left DIV MOD
%left OR
%left AND
%right NOT
%nonassoc IF
%nonassoc ELSE
%nonassoc UMINUS

%%

/* rules 
 * For EBNF -> BNF rules: http://lampwww.epfl.ch/teaching/archive/compilation-ssc/2000/part4/parsing/node3.html
 */

program: 		block END_OF_FILE			{exit(0);}
			;
variable:		IDENTIFIER				{}
			;
block:			declarationsOption BEGINSYM statementGroup END
			;
statementGroup:		statementGroup statement
			| 
			;
declarationsOption:	declarations
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
			| expression DIV expression
			| expression MOD expression
			| expression '/' expression
			| expression '*' expression
			| expression '+' expression
			| expression '-' expression
			| INT '(' expression ')'
			| sign expression %prec UMINUS
			;
sign:			'+' %prec UMINUS		{}
			| '-' %prec UMINUS		{}
			;
comparisonOp:		EQ				{}
			| NEQ				{}
			| LT				{}
			| GT				{}
			| LTE				{}
			| GTE				{}
			;
comparison:		expression comparisonOp expression
			| comparison logicOp comparison %prec AND
			| NOT comparison
			;
logicOp:		AND				{}
			| OR				{}
			;
test:			IF comparison THEN statementGroup elseOption ENDIF
			;
elseOption:		ELSE statementGroup
			|	
			;
loop:			WHILE comparison DO statementGroup ENDWHILE
			| REPEAT statementGroup UNTIL comparison ENDREPEAT
			| FOR variable ASSIGN expression TO expression DO statementGroup ENDFOR
			| PARFOR variable ASSIGN expression TO expression parMod DO statementGroup ENDPARFOR
			;
parMod:			privateVarListOption reduceGroup
			;
privateVarListOption:	PRIVATE varList
			|
			;
reduceGroup:		reduceGroup REDUCE reduceOp varList
			|
			;
reduceOp:		'+'				{}
			|'-'				{}
			|MIN				{}
			|MAX				{}
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
procCall:		variable '(' arguments ')'
			;
arguments:		expression expressionGroup
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

