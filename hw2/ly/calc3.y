%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <stdarg.h>
	#include "calc3.h"

	/***** Bison Debug Flag *****/
	//#define YYDEBUG 1
	//int yydebug = 1;

	/***** Extern Variables *****/
	extern int yylineno;
	extern char *yytext;

	/***** Prototypes *****/
	node *operator(int operation, int nops, ...);
	node *identifier(char* symbol_name);
	node *constant(int value);
	void freeNode(node *p);
	int ex(node *p);
	int yylex(void);
	void yyerror(char *s);

	/***** Symbol Table *****/
	int sym[26];
%}


/***** yylval Data Type *****/
%union {
	long long_val;		// integer value
	double double_val;
	char* str_ptr;		// symbol table index; aka, symbol name
	node *nPtr;		// node pointer
};


/***** Typed Terminal Tokens *****/
%token <long_val> INTNUMBER
%token <double_val> REALNUMBER
%token <str_ptr> IDENTIFIER

/***** Non-Typed Terminal Tokens *****/
%token ASSIGN
%token BEGINSYM END
%token VAR INT REAL
%token WHILE DO ENDWHILE
%token IF THEN ENDIF
%token READ WRITE
%token MIN MAX
%token LPAREN RPAREN
%token LBRACE RBRACE
%token COLON COMMA SEMICOLON
%token END_OF_FILE

/***** Associativity and Precedence Rules *****/
%right ASSIGN
%left AND
%left OR
%left NOT
%left GTE LTE EQ NEQ GT LT
%left PLUS MINUS
%left MULT DIVIDE
%left DIV MOD
%nonassoc UMINUS
%nonassoc IFX
%nonassoc ELSE

/***** Typed Non-Terminals *****/
%type<nPtr> block statement expression statementGroup assignment

%%

/***** Grammar Production Rules *****/

program:		block END_OF_FILE								{ exit(0); }
			;
block:			BEGINSYM statementGroup END							{ ex($2); freeNode($2); }
			| declarations BEGINSYM statementGroup END					{ ex($3); freeNode($3); /* TODO: declarations */ }
			;
declarations:		VAR identifierListGroup						
			;
identifierListGroup:	identifierListGroup identifierList COLON type SEMICOLON
			|
			;
identifierList: 	IDENTIFIER identifierGroup
			;
identifierGroup:	identifierGroup COMMA IDENTIFIER
			|				
			;
type:			basicType 
			| arrayType
			;
arrayType:		basicType LBRACE expression RBRACE						{ /*$$ = $1 == L ? AL : AD;*/ }
			;
basicType:		INT										{ /*$$ = L;*/ }
			| REAL										{ /*$$ = D; */ }
			;
statement:		assignment SEMICOLON								{ $$ = $1; }
			| block SEMICOLON								{ $$ = $1; }
			| expression SEMICOLON								{ $$ = $1; }
			//| SEMICOLON									{ $$ = operator(';', 2, NULL, NULL); }
			| WRITE LPAREN expression RPAREN SEMICOLON					{ $$ = operator(WRITE, 1, $3); }
			| WHILE LPAREN expression RPAREN DO statementGroup ENDWHILE			{ $$ = operator(WHILE, 2, $3, $6); }
			| IF LPAREN expression RPAREN THEN statementGroup ENDIF %prec IFX		{ $$ = operator(IF, 2, $3, $6); }
			| IF LPAREN expression RPAREN THEN statementGroup ELSE statementGroup ENDIF	{ $$ = operator(IF, 3, $3, $6, $8); }
			//| '{' stmt_list '}'								{ $$ = $2; }
			| error SEMICOLON								{ /* empty rule for error production */ }
			;
statementGroup:		statement									{ $$ = $1; }
			| statementGroup statement							{ $$ = operator(SEMICOLON, 2, $1, $2); }
			;
assignment:		IDENTIFIER ASSIGN expression							{ $$ = operator(ASSIGN, 2, identifier($1), $3); }
			| IDENTIFIER LBRACE expression RBRACE ASSIGN expression				{ $$ = operator(ASSIGN, 2, identifier($1), $6); /* TODO: currently assigns as a non array type */ }
			;
expression:		INTNUMBER									{ $$ = constant($1); }
			| REALNUMBER									{ $$ = constant($1); }
			| IDENTIFIER									{ $$ = identifier($1); }
			| MINUS expression %prec UMINUS							{ $$ = operator(UMINUS, 1, $2); }
		//	| FACT expr									{ $$ = operator(FACT, 1, $2); }
		//	| LNTWO expr									{ $$ = operator(LNTWO, 1, $2); }
		//	| expr GCD expr									{ $$ = operator(GCD, 2, $1, $3); }
			| expression PLUS expression							{ $$ = operator(PLUS, 2, $1, $3); }
			| expression MINUS expression							{ $$ = operator(MINUS, 2, $1, $3); }
			| expression MULT expression							{ $$ = operator(MULT, 2, $1, $3); }
			| expression DIVIDE expression							{ $$ = operator(DIVIDE, 2, $1, $3); }
			| expression LT expression							{ $$ = operator(LT, 2, $1, $3); }
			| expression GT expression							{ $$ = operator(GT, 2, $1, $3); }
			| expression GTE expression							{ $$ = operator(GTE, 2, $1, $3); }
			| expression LTE expression							{ $$ = operator(LTE, 2, $1, $3); }
			| expression NEQ expression							{ $$ = operator(NEQ, 2, $1, $3); }
			| expression EQ expression							{ $$ = operator(EQ, 2, $1, $3); }
			| LPAREN expression RPAREN							{ $$ = $2; }
			;

%%

/***** Subroutines *****/

#define SIZEOF_NODETYPE ((char *)&p->constant - (char *)p)

node *constant(int value) {
	node *p;
	size_t nodeSize;
	nodeSize = SIZEOF_NODETYPE + sizeof(constant_node); 	/* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->node_type = CONSTANT_TYPE;					/* copy information */
	p->constant.value = value;
	return p;
}

node *identifier(char* symbol_name) {
	node *p;
	size_t nodeSize;
	nodeSize = SIZEOF_NODETYPE + sizeof(identifier_node);	/* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->node_type = IDENTIFIER_TYPE;					/* copy information */
	p->identifier.symbol_name = symbol_name;
	return p;
}

node *operator(int operation, int nops, ...) {
	va_list ap;
	node *p;
	size_t nodeSize;
	int i;
	nodeSize = SIZEOF_NODETYPE + sizeof(operator_node) + (nops - 1) * sizeof(node*);  /* allocate node */
	if ((p = malloc(nodeSize)) == NULL) {
		yyerror("out of memory");
	}
	p->node_type = OPERATOR_TYPE;		/* copy information */
	p->oper.operation = operation;
	p->oper.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++) {
		p->oper.op[i] = va_arg(ap, node*);
	}
	va_end(ap);
	return p;
}

void freeNode(node *p) {
	int i;
	if (!p) {
		return;
	}
	if (p->node_type == OPERATOR_TYPE) {
		for (i = 0; i < p->oper.nops; i++) {
			freeNode(p->oper.op[i]);
		}
	}
	free (p);
}

/***** yyerror: returns error message 'err' and line number *****/
void yyerror(char *s) {
	fprintf(stderr, "line %d: illegal character (%s)\n", yylineno, yytext);
	//fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

int main(void) {
	yyparse();
	return 0;
}
