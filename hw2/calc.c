/**
 * A recursive descent parser is a top-down parser built
 * from a set of mutually-recursive procedures (or a
 * non-recursive equivalent) where each such procedure
 * usually implements one of the production rules of the
 * grammar. Thus the structure of the resulting program
 * closely mirrors that of the grammar it recognizes.

 * An LL parser is a top-down parser for a subset of the
 * context-free grammars. It parses the input from Left
 * to right, and constructs a Leftmost derivation of the
 * sentence (hence LL, compared with LR parser).
 *
 *		(http://en.wikipedia.org/wiki/Recursive_descent)

Original Grammar:
program	::= program expr '\n' 
	|
expr	::= NUMBER
	| '(' expr ')'
	| expr '+' expr
	| expr '-' expr
	| expr '*' expr
	| expr '/' expr
	| '-' expr


Grammar without left recursion:
program	::= expr program '\n'
	|
expr	::= term '+' expr
	|   term '-' expr
	|   term
term	::= factor '*' term
	|   factor '/' term
	|   factor
factor	::= NUMBER
	| '(' expr ')'	
	| '-' expr

 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "calc.h"

//#define TEST

int symbol;

double expression(void);

void yyerror(char *s) {
	fprintf(stderr, "%s %s at line %d\n", s, yytext, yylineno);
}

void get_symbol() {
	symbol = yylex();
	#ifdef TEST
	printf("symbol got: %u, %f\n", symbol, yylval.double_val);
	#endif
}

int expect(int s) {
	if(accept(s)) {
		return 1;
	}
	yyerror("unexpected symbol");
	return 0;
}

// returns true and advances if the current symbol matches parameter <s>
int accept(int s) {
	if(symbol==s) {
		get_symbol();
		return 1;
	} else {
		return 0;
	}
}

double factor(void) {
//	printf("start factor: %u, %f\n", symbol, yylval.double_val);
	if(symbol==MINUS) {
//		printf("minus here\n");
		return -1 * expression();
	} else if(accept(NUMBER)) {
		return yylval.double_val;
	} else if(accept(LPAREN)) {
		double expression_value = expression();
		expect(RPAREN);
		return expression_value;
	} else {
		yyerror("syntax error");
		get_symbol();
	}
}

double term(void) {
	double left = factor();
	while( symbol == MULT || symbol == DIV ) {
		int s = symbol;
		get_symbol();
		if(s == MULT) {
			left = left * factor();
		} else if(s == DIV) {
			left = left / factor();
		}
	}
	#ifdef TEST
	printf("term returns %f\n", left);
	#endif
	return left;
}

double expression(void) {
	if( symbol == PLUS || symbol == MINUS ) {
		get_symbol();
	}
	double left = term();
	while( symbol == PLUS || symbol == MINUS ) {
		int s = symbol;
		get_symbol();
		if(s==PLUS) {
			left = left + term();
		} else if(s==MINUS) {
			left = left - term();
		}
	}
	return left;
}

double program(void) {
	get_symbol();
	if(symbol==EOF) {
		exit(0);
	} else {
		return expression();
	}
	//expect(EOL);
}

int main() {
	while(1) {
		printf("%f\n", program());
	}
}
