int yylex(void);
extern char* yytext;
extern int yylineno;

typedef enum {NUMBER, PLUS, MINUS, DIV, MULT, LPAREN, RPAREN, EOL} Symbol;

typedef union YYSTYPE
{
        double double_val;
} YYSTYPE;

//extern YYSTYPE yylval;
extern YYSTYPE yylval;
