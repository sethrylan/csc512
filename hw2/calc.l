%{
	#include "calc.h"
	#include <stdlib.h>
	void yyerror(char *);
%}

%%

[0-9]*\.?[0-9]* {
	yylval.double_val = atof(yytext);
	return NUMBER;
	}

[-]	{
	return MINUS;
	}

[\+]    {
        return PLUS;
        }

[\*]    {
        return MULT;
        }

[/]     {
        return EOL;
        }

[\n]    {
        return EOL;
        }

[\t ]	;	/* skip whitespace */

.	yyerror("Unknown character");

%%

int yywrap(void){
	return 1;
}
