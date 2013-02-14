%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "calc3.h"

	//#define YYDEBUG 1
	//int yydebug = 1;

	extern int yylineno;
	extern char *yytext;

	/* prototypes */
	nodeType *opr(int oper, int nops, ...);
	nodeType *id(char* symbol_name);
	nodeType *con(int value);
	void freeNode(nodeType *p);
	int ex(nodeType *p);
	int yylex(void);
	void yyerror(char *s);

	int sym[26];			// symbol table
%}

%union {
	long long_val;		// integer value
	double double_val;
	char* str_ptr;		// symbol table index; aka, symbol name
	nodeType *nPtr;		// node pointer
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

%type <nPtr> statement expression statementGroup assignment

%%

program:		block END_OF_FILE			{ exit(0); }
			;

block:			BEGINSYM statementGroup END			{ ex($2); freeNode($2); }
			//| declarations BEGINSYM statementGroup END
			;

statement:		expression SEMICOLON								{ $$ = $1; }
			//| SEMICOLON									{ $$ = opr(';', 2, NULL, NULL); }
			| PRINT expression SEMICOLON							{ $$ = opr(PRINT, 1, $2); }
			| assignment SEMICOLON								{ $$ = $1; }
			| WHILE LPAREN expression RPAREN DO statementGroup ENDWHILE			{ $$ = opr(WHILE, 2, $3, $6); }
			| IF LPAREN expression RPAREN THEN statementGroup ENDIF %prec IFX		{ $$ = opr(IF, 2, $3, $6); }
			| IF LPAREN expression RPAREN THEN statementGroup ELSE statementGroup ENDIF	{ $$ = opr(IF, 3, $3, $6, $8); }
			//| '{' stmt_list '}'								{ $$ = $2; }
			;

statementGroup:		statement									{ $$ = $1; }
			| statementGroup statement							{ $$ = opr(';', 2, $1, $2); }
			;

assignment:		IDENTIFIER ASSIGN expression							{ $$ = opr(ASSIGN, 2, id($1), $3); }
			| IDENTIFIER LBRACE expression RBRACE ASSIGN expression				{ $$ = opr(ASSIGN, 2, id($1), $6); /* TODO: currently assigns as a non array type */ }
			;

expression:		INTNUMBER								{ $$ = con($1); }
			| REALNUMBER									{ $$ = con($1); }
			| IDENTIFIER									{ $$ = id($1); }
			| MINUS expression %prec UMINUS							{ $$ = opr(UMINUS, 1, $2); }
		//	| FACT expr									{ $$ = opr(FACT, 1, $2); }
		//	| LNTWO expr									{ $$ = opr(LNTWO, 1, $2); }
		//	| expr GCD expr									{ $$ = opr(GCD, 2, $1, $3); }
			| expression PLUS expression							{ $$ = opr(PLUS, 2, $1, $3); }
			| expression MINUS expression							{ $$ = opr(MINUS, 2, $1, $3); }
			| expression MULT expression							{ $$ = opr(MULT, 2, $1, $3); }
			| expression DIVIDE expression							{ $$ = opr(DIVIDE, 2, $1, $3); }
			| expression LT expression							{ $$ = opr(LT, 2, $1, $3); }
			| expression GT expression							{ $$ = opr(GT, 2, $1, $3); }
			| expression GTE expression							{ $$ = opr(GTE, 2, $1, $3); }
			| expression LTE expression							{ $$ = opr(LTE, 2, $1, $3); }
			| expression NEQ expression							{ $$ = opr(NEQ, 2, $1, $3); }
			| expression EQ expression							{ $$ = opr(EQ, 2, $1, $3); }
			| LPAREN expression RPAREN							{ $$ = $2; }
			;




%%

/***********************************************
 * subroutines                                 *
 ***********************************************/

#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
	nodeType *p;
	size_t nodeSize;
	nodeSize = SIZEOF_NODETYPE + sizeof(conNodeType); 	/* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->type = typeCon;					/* copy information */
	p->con.value = value;
	return p;
}

nodeType *id(char* symbol_name) {
	nodeType *p;
	size_t nodeSize;
	nodeSize = SIZEOF_NODETYPE + sizeof(idNodeType);	/* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->type = typeId;					/* copy information */
	p->id.symbol_name = symbol_name;
	return p;
}

nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	size_t nodeSize;
	int i;
	nodeSize = SIZEOF_NODETYPE + sizeof(oprNodeType) + (nops - 1) * sizeof(nodeType*);  /* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->type = typeOpr;		/* copy information */
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++) {
		p->opr.op[i] = va_arg(ap, nodeType*);
	}
	va_end(ap);
	return p;
}

void freeNode(nodeType *p) {
	int i;
	if (!p) {
		return;
	}
	if (p->type == typeOpr) {
		for (i = 0; i < p->opr.nops; i++) {
			freeNode(p->opr.op[i]);
		}
	}
	free (p);
}

/*
 * yyerror - returns error msg "err" and line number
 */
void yyerror(char *s) {
	fprintf(stderr, "line %d: illegal character (%s)\n", yylineno, yytext);
	//fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

int main(void) {
	yyparse();
	return 0;
}
