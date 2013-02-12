%{
#ifndef ASSIGN
#include "pseudo.tab.h"
#endif
%}

%option	yylineno

letter	[A-Za-z]
digit	[0-9]
id	{letter}({letter}|{digit})*
intnum	{digit}+
realnum	{digit}+(\.{digit}+)?

%%

":"	{  return COLON; }
"VAR"	{  return VAR; }
","	{  return COMMA; }
":="	{ return (ASSIGN); }
"+"	{ return (PLUS); }
"-"	{ return (MINUS); }
"*"	{ return (TIMES); }
"/"	{ return (DIVIDE); }
"="	{ return (EQ); }
"<>"	{ return (NE); }
"<="	{ return (LE); }
"<"	{ return (LT); }
">="	{ return (GE); }
">"	{ return (GT); }
"("	{ return (LPAREN); }
")"	{ return (RPAREN); }
"["	{ return (LBRACE); }
"]"	{ return (RBRACE); }
";"	{ return (SEMI); }
"DIV"	{ return (DIV); }
"MOD"	{ return (MOD); }
"OR"	{ return (OR); }
"AND"	{ return (AND); }
"NOT"	{ return (NOT); }
"BEGIN"	{ return (BEGIN_K); }
"END"	{ return (END); }
"IF"	{ return (IF); }
"THEN"	{ return (THEN); }
"ELSE"	{ return (ELSE); }
"ENDIF"	{ return (ENDIF); }
"WHILE"	{ return (WHILE); }
"DO"	{ return (DO); }
"ENDWHILE"	{ return (ENDWHILE); }
"REPEAT"	{ return (REPEAT); }
"UNTIL"	{ return (UNTIL); }
"ENDREPEAT"	{ return (ENDREPEAT); }
"FOR"	{ return (FOR); }
"TO"	{ return (TO); }
"ENDFOR"	{ return (ENDFOR); }
"READ"	{ return (READ); }
"WRITE"	{ return (WRITE); }


"PARFOR"	{  return PARFOR; }
"ENDPARFOR"	{  return ENDPARFOR; }
"PRIVATE"	{  return PRIVATE; }
"REDUCE"	{  return REDUCE; }
"PROC"		{  return PROC; }	
"ENDPROC"	{  return ENDPROC; }	
"PARPROC"	{  return PARPROC; }	
"ENDPARPROC"	{  return ENDPARPROC; }	
"IN"		{  return IN; }	
"OUT"		{  return OUT; }	
"INOUT"	{  return INOUT; }	
"REF"		{  return REF; }

"MIN"		{  return MIN; }
"MAX"		{  return MAX; }
"REAL"		{  return REAL; }
"INT"		{  return INT; }

{id}	{ yylval.str_ptr = (char *) strdup(yytext); return (ID); }
{intnum}	{ yylval.int_val = atoi(yytext); return (INTNUMBER); }
{realnum}	{ sscanf(yytext, "%lf", &yylval.double_val); return (REALNUMBER); }
[ \t\n]	;
.	{ char msg[] = "lexical error at token ";
	  char *s = (char *) calloc(1, strlen(msg) + yyleng + 1);
	  strcpy(s, msg);
	  strcpy(&s[strlen(s)], yytext);
          yyerror(s);
	}

%%

int yywrap(void) {
  return 1;
}
