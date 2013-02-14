%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "calc3.h"

	/* prototypes */
	nodeType *opr(int oper, int nops, ...);
	nodeType *id(char* symbol_name);
	nodeType *con(int value);
	void freeNode(nodeType *p);
	int ex(nodeType *p);
	int yylex(void);
	void yyerror(char *s);
	int sym[26];                    /* symbol table */
%}

%union {
	long long_val;		/* integer value */
	double double_val;
	char* str_ptr;		/* symbol table index; aka, symbol name */
	nodeType *nPtr;		/* node pointer */
};

%token <long_val> INTNUMBER
%token <double_val> REALNUMBER
%token <str_ptr> IDENTIFIER

%token ASSIGN
%token BEGINSYM END
%token WHILE DO ENDWHILE
%token IF THEN ENDIF
%token PRINT

%token MIN MAX
%token LPAREN RPAREN
%token LBRACE RBRACE
%token COLON COMMA SEMICOLON
%token END_OF_FILE


%right ASSIGN
//%left AND
//%left OR
//%left NOT
%left GTE LTE EQ NEQ GT LT
%left PLUS MINUS
%left MULT DIVIDE
%left DIV MOD
%nonassoc UMINUS
%nonassoc IFX
%nonassoc ELSE

%type <nPtr> stmt expr stmt_list assignment

%%

program:
	block END_OF_FILE			{ exit(0); }
	;

block:	BEGINSYM stmt_list END			{ ex($2); freeNode($2); }
	//| declarations BEGINSYM statementGroup END
	;
//function:	function stmt         { ex($2); freeNode($2); }
//        |
//        ;
stmt:
	SEMICOLON							{ $$ = opr(';', 2, NULL, NULL); }
	| expr SEMICOLON						{ $$ = $1; }
	| PRINT expr SEMICOLON						{ $$ = opr(PRINT, 1, $2); }
	| assignment SEMICOLON						{ $$ = $1; }
	| WHILE LPAREN expr RPAREN DO stmt_list ENDWHILE		{ $$ = opr(WHILE, 2, $3, $6); }
	| IF LPAREN expr RPAREN THEN stmt_list ENDIF %prec IFX		{ $$ = opr(IF, 2, $3, $6); }
	| IF LPAREN expr RPAREN THEN stmt_list ELSE stmt_list ENDIF	{ $$ = opr(IF, 3, $3, $6, $8); }
	| '{' stmt_list '}'						{ $$ = $2; }
	;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

assignment:		IDENTIFIER ASSIGN expr					{ $$ = opr(ASSIGN, 2, id($1), $3); }
			| IDENTIFIER LBRACE expr RBRACE ASSIGN expr		{ $$ = opr(ASSIGN, 2, id($1), $6); /* currently assigns as a non array type */ }
			;
expr:	INTNUMBER				{ $$ = con($1); }
	| REALNUMBER				{ $$ = con($1); }
	| IDENTIFIER				{ $$ = id($1); }
	| MINUS expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
//	| FACT expr             { $$ = opr(FACT, 1, $2); }
//	| LNTWO expr            { $$ = opr(LNTWO, 1, $2); }
//	| expr GCD expr         { $$ = opr(GCD, 2, $1, $3); }
	| expr PLUS expr         { $$ = opr(PLUS, 2, $1, $3); }
	| expr MINUS expr         { $$ = opr(MINUS, 2, $1, $3); }
	| expr MULT expr         { $$ = opr(MULT, 2, $1, $3); }
	| expr DIVIDE expr         { $$ = opr(DIVIDE, 2, $1, $3); }
	| expr LT expr         { $$ = opr(LT, 2, $1, $3); }
	| expr GT expr         { $$ = opr(GT, 2, $1, $3); }
	| expr GTE expr          { $$ = opr(GTE, 2, $1, $3); }
	| expr LTE expr          { $$ = opr(LTE, 2, $1, $3); }
	| expr NEQ expr          { $$ = opr(NEQ, 2, $1, $3); }
	| expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
	| LPAREN expr RPAREN          { $$ = $2; }
	;

%%

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *id(char* symbol_name) {
    nodeType *p;
    size_t nodeSize;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.symbol_name = symbol_name;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t nodeSize;
    int i;

    /* allocate node */
    nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) +
        (nops - 1) * sizeof(nodeType*);
    if ((p = malloc(nodeSize)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
