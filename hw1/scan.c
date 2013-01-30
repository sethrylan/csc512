/*
Lexical analyzer which scans and returns a double
on the stack with the token NUMBER, or the character
if an operator (+-* / and newline). Whitespace 
(space and tabs) is ignored. Increments yylineno at
each newline.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
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

char *to_str(char c) {
	char *t = (char *) malloc(2);
	t[0] = c;
	t[1] = '\0';
	return t;
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
		char s[] = "";

		#ifdef TEST
		printf("c = %c; s = %s\n", c, s);
		#endif

		s1:
		if(isdigit(c)) {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s1 (%c is digit; s=%s)\n",c,s);
			#endif
			goto s3;
		} else if(c=='.') {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s1 (%c is .; s=%s)\n",c,s);
			#endif
			goto s2;
		} else if(is_op(c)) {
			#ifdef TEST
			printf("s1 (%c is op; s=%s)\n",c,s);
			#endif
			goto s5;
		} else {
			#ifdef TEST
			printf("s1 (error)\n");
			#endif
			goto err;
		}

		s2: c = getc(yyin);
		if(isdigit(c)) {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s2 (%c is digit; s=%s)\n",c,s);
			#endif
			c = getc(yyin);
			goto s4;
		} else {
			yylval.double_val = atof(s);
			#ifdef TEST
			printf("s2 (return NUMBER; s=%s)\n",s);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s3: c = getc(yyin);
		if (isdigit(c)) {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s3 (%c is digit; s=%s)\n",c,s);
			#endif
			goto s3;
		} else if(c=='.') {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s3 (%c is .; s=%s)\n",c,s);
			#endif
			goto s2;
		} else {
			yylval.double_val = atof(s);
			#ifdef TEST
			printf("s3 (return NUMBER; s=%s)\n",s);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s4: c = getc(yyin);
		if (isdigit(c)) {
			strcat(s, to_str(c));
			#ifdef TEST
			printf("s4 (%c is digit; s=%s)\n",c,s);
			#endif
			goto s4;
		} else {
			yylval.double_val = atof(s);
			#ifdef TEST
			printf("s4 (return NUMBER; s=%s)\n",s);
			#endif
			ungetc(c, yyin);
			return NUMBER;
		}

		s5: 
		if(c == '\n') {
			#ifdef TEST
			printf("s5 (c is newline; s=%s)\n",s);
			#endif
			yylineno++;
		}
		#ifdef TEST
		printf("s5 (return character, %c; s=%s)\n",c,s);
		#endif
		return c;

		err: yyerror("Unknown character");

	}


}
