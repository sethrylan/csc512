%{
	#include <stdlib.h>
	#include "calc3.h"
	#include "y.tab.h"

	void yyerror(char *);

	#define yyterminate() return END		// return END token on termination
%}

%option	yylineno

/***** Regular Expression Definitions *****/
digit		[0-9]
letter		[a-zA-Z_$]
whitespace	[ \t\n\r]
id		{letter}({letter}|{digit})*
intnum		{digit}+
/*realnum	{digit}+\.?{digit}* | {digit}*\.{digit}+*/
realnum	{digit}+(\.{digit}+)?

%%

":="			{return ASSIGN;}
"BEGIN"			{return BEGINSYM;}
"END"			{return END;}

"VAR"			{return VAR;}
"INT"			{return INT;}
"REAL"			{return REAL;}

"IF"			{return IF;}
"THEN"			{return THEN;}
"ELSE"			{return ELSE;}
"ENDIF"			{return ENDIF;}

"WHILE"			{return WHILE;}
"DO"			{return DO;}
"ENDWHILE"		{return ENDWHILE;}

"READ"			{return READ;}
"WRITE"			{return WRITE;}

"AND"			{return AND;}
"OR"			{return OR;}
"NOT"			{return NOT;}
"="			{return EQ;}
"<>"			{return NEQ;}
">"			{return GT;}
"<"			{return LT;}
">="			{return GTE;}
"<="			{return LTE;}
"+"			{return PLUS;}
"-"			{return MINUS;}
"*"			{return MULT;}
"/"			{return DIVIDE;}
"DIV"			{return DIV;}
"MOD"			{return MOD;}
"MIN"			{return MIN;}
"MAX"			{return MAX;}
"("			{return LPAREN;}
")"			{return RPAREN;}
"["			{return LBRACE;}
"]"			{return RBRACE;}
":"			{return COLON;}
","			{return COMMA;}
";"			{return SEMICOLON;}
<<EOF>>			{return END_OF_FILE;}

{whitespace}		;  /* ignore whitespace */

{id}			{ yylval.str_ptr = strdup(yytext);
			  /*
			  symrec *s;
			  s = get_symbol(yylval.str_ptr);
			  if (s == 0)
				s = add_symbol(yylval.str_ptr, IDENTIFIER);	// TODO: var_type should be of kind L/D/AL/AD
			  yylval.table_ptr = s;
			  */
			  return IDENTIFIER;
			}

{intnum}		{ yylval.long_val = atol(yytext); 
			  return (INTNUMBER);
			}

{realnum}		{ sscanf(yytext, "%lf", &yylval.double_val); 
			  return (REALNUMBER);
			}

.			{ char msg[] = "lexical error at token ";
			  char *s = (char *) calloc(1, strlen(msg) + yyleng + 1);
			  strcpy(s, msg);
			  strcpy(&s[strlen(s)], yytext);
        		  yyerror(s);
			}


%%

/***** Subroutines *****/

int yywrap(void) {
	return 1;
}

