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
%token WHILE IF PRINT 

%right ASSIGN
%left GTE LTE EQ NEQ GT LT
%left PLUS MINUS
%left MULT DIVIDE
%nonassoc UMINUS
%nonassoc IFX
%nonassoc ELSE

%type <nPtr> stmt expr stmt_list

%%

program:
        function                { exit(0); }
        ;

function:
          function stmt         { ex($2); freeNode($2); }
        | /* NULL */
        ;

stmt:
          ';'                            { $$ = opr(';', 2, NULL, NULL); }
        | expr ';'                       { $$ = $1; }
        | PRINT expr ';'                 { $$ = opr(PRINT, 1, $2); }
        | IDENTIFIER ASSIGN expr ';'          { $$ = opr(ASSIGN, 2, id($1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = opr(WHILE, 2, $3, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

expr:
	INTNUMBER				{ $$ = con($1); }
	| IDENTIFIER              { $$ = id($1); }
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
	| '(' expr ')'          { $$ = $2; }
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
