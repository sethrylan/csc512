/*
Lexical analyzer which scans and returns a double
on the stack with the token NUMBER, or the character
if an operator (+-* / and newline). Whitespace 
(space and tabs) is ignored. Increments yylineno at
each newline.
*/

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "calc.tab.h"

FILE *yyin;
char* yytext;
int yylineno;

/*
int yywrap(void){
        return 1;
}
*/

int is_op(int c) {
	if(c == '-' || c == '+' || c == '*' || c == '/' || c == '\n') {
		return 1;
	} else {
		return 0;
	}
}

//char append(char *out, char *in) {
//    strcat(out, in);
//    return out;
//}

int yylex(void) {
	if(!yyin) {
		yyin = stdin;
	}

	int c;

	while(c = getc(yyin)){
	char buffer[] = "";

	s0:
	if(isdigit(c)) {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s3;
	} else if(c=='.') {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s2;
	} else if(is_op(c)) {
		goto s5;
	} else {
		goto err;
	}

	s2:
	if(isdigit(c)) {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s4;
	} else {
		yylval.double_val = atof(buffer);
		ungetc(c, yyin);
		return NUMBER;
	}

	s3:
	if (isdigit(c)) {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s3;
	} else if(c=='.') {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s2;
	} else {
		yylval.double_val = atof(buffer);
		ungetc(c, yyin);
		return NUMBER;
	}

	s4:
	if (isdigit(c)) {
		sprintf(buffer, "%s%c", buffer, c);
		c = getc(yyin);
		goto s4;
	} else {
		yylval.double_val = atof(buffer);
		ungetc(c, yyin);
		return NUMBER;
	}

	s5:
	if(c == '\n') {
		yylineno++;
	}
	return c;
	
	err:
	yyerror("Unknown character");

}
/*
	while(c=getc(yyin)) {
		if(isdigit(c)) {
			double value = c - '0';
			while(isdigit(c = getc(yyin))) {
				value = (10 * value) + (c - '0');
			}
			yylval.double_val = value;
			ungetc(c, yyin);
			return NUMBER;
		}
		if(is_op(c)) {
			if(c == '\n') {
				yylineno++;
			}
			return c;
		}
		if(c != ' ' || c != '\t') {
		       yyerror("Unknown character");
		}
	}

*/

// scan number
//	if(isdigit(c) || c == '.') {
//		ungetc(c, yyin);
//		scanf("%lf", &(yylval.double_val));
//		return NUMBER;
//	}

}
