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

#define TEST 1

FILE *yyin;
char* yytext;
int yylineno;

//%option noyywrap

int is_op(int c) {
	if(c == '-' || c == '+' || c == '*' || c == '/' || c == '\n') {
		return 1;
	} else {
		return 0;
	}
}

int yylex(void) {
	if(!yyin) {
		#ifdef TEST
		printf("yyin is null; assigning stdin\n");
		#endif
		yyin = stdin;
	}

	int c;

	while(c = getc(yyin)){
		char buffer[] = "";

		#ifdef TEST
		printf("c = %c; buffer = %s\n", c, buffer);
		#endif

		s1:
		if(isdigit(c)) {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s1 (%c is digit; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s3;
		} else if(c=='.') {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s1 (%c is .; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s2;
		} else if(is_op(c)) {
			#ifdef TEST
			printf("s1 (%c is op; buffer=%s)\n",c,buffer);
			#endif
			goto s5;
		} else {
			#ifdef TEST
			printf("s1 (error)\n");
			#endif
			goto err;
		}

		s2:
		if(isdigit(c)) {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s2 (%c is digit; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s4;
		} else {
			yylval.double_val = atof(buffer);
			#ifdef TEST
			printf("s2 (return NUMBER; buffer=%s)\n",buffer);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s3:
		if (isdigit(c)) {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s3 (%c is digit; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s3;
		} else if(c=='.') {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s3 (%c is .; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s2;
		} else {
			yylval.double_val = atof(buffer);
			#ifdef TEST
			printf("s3 (return NUMBER; buffer=%s)\n",buffer);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s4:
		if (isdigit(c)) {
			sprintf(buffer, "%s%c", buffer, c);
			#ifdef TEST
			printf("s4 (%c is digit; buffer=%s)\n",c,buffer);
			#endif
			c = getc(yyin);
			goto s4;
		} else {
			yylval.double_val = atof(buffer);
			#ifdef TEST
			printf("s4 (return NUMBER; buffer=%s)\n",buffer);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s5:
		if(c == '\n') {
			#ifdef TEST
			printf("s5 (c is newline; buffer=%s)\n",buffer);
			#endif
			yylineno++;
		}
		#ifdef TEST
		printf("s5 (return character, %c; buffer=%s)\n",c,buffer);
		#endif
		return c;

		err:
		yyerror("Unknown character");

	}
}
