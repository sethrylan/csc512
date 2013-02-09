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
 *    (http://en.wikipedia.org/wiki/Recursive_descent)

program ::= program expr '\n' 
        |
expr    ::= NUMBER
        | '(' expr ')'
        | expr '+' expr
        | expr '-' expr
        | expr '*' expr
        | expr '/' expr
        | ' -' expr

program ::= expr program '\n'
        |
expr    ::= term expr_p
expr_p  ::= PLUS term expr_p
        |   MINUS term expr_p
        | 
term    ::= factor term_p
terp_p  ::= MULT factor term_p
        |   DIV factor term_p
        |
factor  ::=  LPAREN expr RPAREN
        | NUMBER
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
int yylex(void);
void expression(void);
extern char* yytext;
extern int yylineno;

typedef union YYSTYPE {
        double double_val;
} YYSTYPE;

YYSTYPE yylval;

typedef enum {NUMBER, PLUS, MINUS, DIV, MULT, LPAREN, RPAREN, EOL} Symbol;

Symbol symbol;


void yyerror(char *s) {
  fprintf(stderr, "%s %s at line %d\n", s, yytext, yylineno);
}

void get_symbol() {
  symbol = yylex();
}

int expect(Symbol s) {
  if(accept(s)) {
    return 1;
  }
  yyerror("unexpected symbol");
  return 0;
}

int accept(Symbol s ) {
  if(symbol==s) {
    get_symbol();
    return 1;
  } else {
    return 0;
  }
}


void factor(void) {
  if(accept(NUMBER)) {
    ;
  } else if(accept(LPAREN)) {
    expression();
    expect(RPAREN);
  } else {
    error("syntax error");
    get_symbol();
  }
}

void term(void) {
  factor();
  while( symbol == MULT || symbol == DIV ) {
    get_symbol();
    factor();
  }
}

void expression(void) {
  if( symbol == PLUS || symbol == MINUS ) {
    get_symbol();
  } 
  term();
  while( symbol == PLUS || symbol == MINUS ) {
    get_symbol();
    term();
  }
}



void program(void) {
  get_symbol();
  expression();
  expect(EOL);
}
