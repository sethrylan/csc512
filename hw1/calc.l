%{
	#include "calc.tab.h"
	#include <stdlib.h>
	void yyerror(char *);
%}

%%

[0-9]*\.?[0-9]* {
	yylval.double_val = atof(yytext);
	return NUMBER;
	}

[-+\*/\n] {
	return *yytext;
	}

[\t]	;	/* skip whitespace */

.	yyerror("Unknown character");

%%

int yywrap(void){
	return 1;
}
