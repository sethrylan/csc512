%{
	#ifndef ASSIGN
	#include "pseudo.tab.h"
	#endif
	
	#define yyterminate() return END

%}

%option	yylineno

/* defninitions: digit, letter, ... */
digit		[0-9]
alpha		[a-fA-F]
whitespace	[ \t\n\r]
operator	[-+/\*]|DIV|MOD
id		{alpha}({alpha}|{digit})*

%%

":="			{return ASSIGN;}
VAR			{return VAR;}
BEGIN			{return BEGINSYM;}
END			{return END;}
IF			{return IF;}
THEN			{return THEN;}
ELSE			{return ELSE;}
ENDIF			{return ENDIF;}
WHILE			{return WHILE;}
DO			{return DO;}
ENDWHILE		{return ENDWHILE;}
REPEAT			{return REPEAT;}
UNTIL			{return UNTIL;}
ENDREPEAT		{return ENDREPEAT;}
FOR			{return FOR;}
TO			{return TO;}
ENDFOR			{return ENDFOR;}
PARFOR			{return PARFOR;}
PRIVATE			{return PRIVATE;}
REDUCE			{return REDUCE;}
ENDPARFOR		{return ENDPARFOR;}
PROC			{return PROC;}
ENDPROC			{return ENDPROC;}
PARPROC			{return PARPROC;}
ENDPARPROC		{return ENDPARPROC;}
IN			{return IN;}
OUT			{return OUT;}
INOUT			{return INOUT;}
REF			{return REF;}
READ			{return READ;}
WRITE			{return WRITE;}
INT			{return INT;}
REAL			{return REAL;}
AND			{return AND;}
OR			{return OR;}
NOT			{return NOT;}
"="			{return EQ;}
"<>"			{return NEQ;}
">"			{return GT;}
"<"			{return LT;}
">="			{return GTE;}
"<="			{return LTE;}
"DIV"			{return DIV;}
"MOD"			{return MOD;}
"MIN"			{return MIN;}
"MAX"			{return MAX;}
<<EOF>>			{return END_OF_FILE;}

{whitespace}		;  /* ignore whitespace */

{id}			{yylval.str_ptr = strdup(yytext);
			    return IDENTIFIER;}
			
-?{digit}*\.?{digit}* 	{yylval.double_val = atof(yytext);
			 return NUMBER;
			 // TODO: use resWord() and symLookup to return symbol table index
			}
			
{operator}		{return *yytext;}

[,:;\[\]()]		{return *yytext;}



.	yyerror("Unknown character");

%%

/* subroutines */

int yywrap(void) {
	return 1;
}
