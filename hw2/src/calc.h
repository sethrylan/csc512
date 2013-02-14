
typedef union YYSTYPE
{
	   double double_val;
} YYSTYPE;

int yylex(void);
extern char* yytext;
extern int yylineno;
extern YYSTYPE yylval;

// symbols coincide with ascii codes
enum yytokentype {
	NUMBER	= 258,
	PLUS	= 43,
	MINUS	= 45,
	DIV	= 47,
	MULT	= 42,
	LPAREN	= 40,
	RPAREN	= 41,
	EOL	= 10
   };




