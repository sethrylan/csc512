%{
#include <stdio.h>
#include <stdlib.h>
%}

/* defintions: token, precedence, types etc. */

%union {
	double	double_val;
	int	int_val;
	char*	str_ptr;
}

%token ASSIGN VAR BEGINSYM END
%token IF THEN ELSE ENDIF
%token WHILE DO ENDWHILE
%token REPEAT UNTIL ENDREPEAT
%token FOR TO ENDFOR PARFOR ENDPARFOR PRIVATE
%token PROC ENDPROC
%token READ WRITE
%token IN OUT INOUT
%token AND OR NOT
%token EQ NEQ LT GT LTE GTE
%token<str_ptr> IDENTIFIER
%token<double_val> INT REAL NUMBER

%left GTE LTE EQ NEQ GT LT
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%type<double_val> expr

%%

/* rules */
/* Notice: use empty action { } for rules with typed tokens
 * to avoid type conflicts
 */

program:
	program expr '\n' { printf("%f\n", $2); }
	|
	;

expr:
	INT | REAL
        | expr '*' expr         { $$ = $1 * $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	;



%%

/* subroutines */
#include "pseudo.yy.c"

int main(int argc,char *argv[]) {
  char *result;
  result = (char *) yyparse();
  return(1);
}

/*
 * yyerror - returns error msg "err" and line number
 */
int yyerror(char *err) {
  fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

