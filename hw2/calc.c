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

program ::= program expr '\n' 
				|
expr		::= NUMBER
				| '(' expr ')'
				| expr '+' expr
				| expr '-' expr
				| expr '*' expr
				| expr '/' expr
				| ' -' expr

program ::= expr program '\n'
				|
expr		::= term expr_p
expr_p	::= PLUS term expr_p
				|	 MINUS term expr_p
				| 
term		::= factor term_p
terp_p	::= MULT factor term_p
				|	 DIV factor term_p
				|
factor	::=	LPAREN expr RPAREN
				| NUMBER
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
	if(accept(NUMBER)) {
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
	double term_result = factor();
	while( symbol == MULT || symbol == DIV ) {
		int s = symbol;
		get_symbol();
		if(s == MULT) {
			term_result = term_result * factor();
		} else if(s == DIV) {
			term_result = term_result / factor();
		}
	}
	#ifdef TEST
	printf("term returns %f\n", term_result);
	#endif
	return term_result;
}

double expression(void) {
	if( symbol == PLUS || symbol == MINUS ) {
		get_symbol();
	}
	double expression_result = term();
	while( symbol == PLUS || symbol == MINUS ) {
		int s = symbol;
		get_symbol();
		if(s==PLUS) {
			expression_result = expression_result + term();
		} else if(s==PLUS) {
			expression_result = expression_result - term();
		}
	}
	return expression_result;
}

double program(void) {
	get_symbol();
	double program_result = expression();
	//expect(EOL);
	return program_result;
}

int main() {
	while(1) {
		printf("%f\n", program());
	}
}
