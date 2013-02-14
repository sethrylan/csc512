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
PROGRAM -> PROGRAM EXPR newline
        |.
EXPR    -> number
        | ( EXPR )
        | EXPR plus EXPR
        | EXPR minus EXPR
        | EXPR mult EXPR
        | EXPR div EXPR
        | minus expr .

Grammer without left recursion:
PROGRAM-> EXPR PROGRAM newline
        | .
EXPR-> TERM plus EXPR
	|   TERM minus  EXPR
	|   TERM .
TERM-> FACTOR mult TERM 
	|   FACTOR div TERM 
	|   FACTOR .
FACTOR-> number
	| ( EXPR )
	| minus EXPR .


Grammar after left-factoring

PROGRAM -> EXPR newline .
EXPR	-> TERM EXPR_TAIL.
EXPR_TAIL -> plus TERM EXPR_TAIL
	| minus TERM EXPR_TAIL
	| .
TERM -> FACTOR_P TERM_TAIL .
TERM_TAIL-> mult FACTOR_P TERM_TAIL 
	| div FACTOR_P TERM_TAIL 
	| .
FACTOR_P  -> minus FACTOR
	| FACTOR.
FACTOR -> number
	| (  EXPR ).


 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "calc.h"

//#define TEST

int symbol;

double expr(void);
double factor(void);
double term(void);

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
	if(match(s)) {
		return 1;
	}
	yyerror("Unexpected Symbol");
	return 0;
}

// returns true and advances if the current symbol matches parameter <s>
int match(int s) {
	if(symbol==s) {
		get_symbol();
		return 1;
	} else {
		return 0;
	}
}

/*
double factor(void) {
	if(symbol==LPAREN) {
		match(LPAREN);
		double left = expression();
		expect(RPAREN);
		return left;
	} else if(symbol==NUMBER) {
		match(NUMBER);
		return yylval.double_val;
	} else if(symbol==MINUS) {
		match(MINUS);
		return -1*factor();
	} else {
		yyerror("syntax error");
		get_symbol();
	}
}
*/

double factor_p() {
	switch(symbol) {
		case MINUS:
			match(MINUS);
			return -1*factor();
			break;
		case NUMBER:
		case LPAREN: 
			return factor(); 
			break;
		default:
			yyerror("Unexpected symbol");
			break;
	  }
}

double factor() {
	double expr_val;
	double factor_val;
	switch(symbol) {
		case NUMBER:
			factor_val = yylval.double_val;
			match(NUMBER);
			return factor_val;
			break;
		case LPAREN: 
			match(LPAREN); 
			expr_val = expr(); 
			match(RPAREN); 
			return expr_val;
			break;
		default:
			yyerror("Unexpected symbol");
			break;
	  }
}


double term_tail(double lhs_val) {
	double right;
	switch(symbol) {
		case MULT: 
			match(MULT);
			right = factor(); 
			return term_tail(lhs_val * right);
			break;
		case DIV:
			match(DIV);
			right = factor(); 
			return term_tail(lhs_val / right);
			break;
		case RPAREN:
		case EOL:
		case PLUS: 
			return lhs_val; 
			break;
		case MINUS: 
			return lhs_val; 
			break;
		default: 
			yyerror("Unexpected symbol"); 
			break;    
	  }
}

double term() { 
	double left = factor_p(); 
	return term_tail(left); 
}


double expr_tail(double lhs_val) {
	double right;
	switch(symbol) {
		case PLUS: 
			match(PLUS);
			right = term(); 
			return expr_tail(lhs_val + right);
			break;
		case MINUS:
			match(MINUS);
			right = term(); 
			return expr_tail(lhs_val - right);
			break;
		case RPAREN:
		case EOL:
			return lhs_val;
			break;
		default:
			yyerror("Unexpected symbol");
			break;
	}
}

double expr(void) {
	double left = term();
	return expr_tail(left);
}

double program(void) {
	get_symbol();
	if(symbol==EOF) {
		exit(0);
	} else {
		return expr();
	}
}

int main() {
	while(1) {
		printf("%f\n", program());
	}
}
