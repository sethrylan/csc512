%{
#include <stdio.h>
#include <stdlib.h>
%}

/* add: token, precedence, types etc. */

%union {
	double double_val;
}

%token ASSIGN
%token<double_val> NUMBER
%left '+' '-' '*' '/'
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
	NUMBER 
        | expr '*' expr         { $$ = $1 * $3; }
	| expr '/' expr		{ $$ = $1 / $3; }
	| expr '+' expr		{ $$ = $1 + $3; }
	| expr '-' expr		{ $$ = $1 - $3; }
	;



%%

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

