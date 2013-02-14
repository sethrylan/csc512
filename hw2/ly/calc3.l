%{
	#include <stdlib.h>
	#include "calc3.h"
	#include "y.tab.h"
	void yyerror(char *);

//	#define yyterminate() return END
%}


%option	yylineno

/* defninitions: digit, letter, ... */
digit		[0-9]
letter		[a-zA-Z_$]
whitespace	[ \t\n\r]
id		{letter}({letter}|{digit})*
intnum		{digit}+
/*realnum	{digit}+\.?{digit}* | {digit}*\.{digit}+*/
realnum	{digit}+(\.{digit}+)?

%%


[(){}.]	{
		return *yytext;
		}

":="			{return ASSIGN;}
">"			{return GT;}
"<"			{return LT;}
">="			{return GTE;}
"<="			{return LTE;}
"+"			{return PLUS;}
"-"			{return MINUS;}
"*"			{return MULT;}
"/"			{return DIVIDE;}
"=="			{return EQ;}
"!="			{return NEQ;}
"while"			{return WHILE;}
"if"			{return IF;}
"else"			{return ELSE;}
"print"			{return PRINT;}
";"			{return SEMICOLON;}

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

/* subroutines */

int yywrap(void) {
	return 1;
}

