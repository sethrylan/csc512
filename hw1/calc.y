%{
	#include <stdio.h>
	int yylex(void);
	extern char* yytext;	
	extern int yylineno; 
	void yyerror(char *);
%}

%union {
	double double_val;
}

%token<double_val> NUMBER
%left '+' '-'
%left '*' '/'
%type<double_val> expr

%%

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
void yyerror(char *s) {
	fprintf(stderr, "%s %s at line %d\n", s, yytext, yylineno);
}

int main(void) {
	yyparse();
	return 0;
}
