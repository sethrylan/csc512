%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>

	/* http://www.cs.tut.fi/~jkorpela/round.html */
	#define round(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

	extern FILE *yyin;
	extern FILE *yyout;

	extern int yylineno;
	extern char *yytext;

	int yylex(void);
	int iVerbose = 1;

	int label = 0;
	int maxstacksize = 0;
	int stacksize = 0;

	int maxsym = 0;

	char s[1024], t[1024];
	char l1[1024], go_l1[1024];
	char l2[1024], goto_l2[1024];

	typedef enum  {
		L = 0,  /*long*/
		D = 1,  /*double*/
		AL = 2, /*long array*/
		AD = 3  /*double array*/
	} var_type;

	struct var_info {
		int offset;
		var_type type;
	};
	typedef struct var_info var_info;

	struct symrec {
		char *symbol_name;  /* name of symbol */
		var_info var_info;
		union {
			long long_val;
			double double_val;
		} value;
		struct symrec *next;  /* link field */
	};
	typedef struct symrec symrec;

	typedef struct scope {
		//syment sym_table;
		struct symrec* symbol_table;
		struct scope* parent;
	} *scope;


	void beginScope();
	void endScope();

	symrec* add_symbol(char *symbol_name, var_type symbol_type); /* returns stack location for variable s*/

	/* return metadata for symbol s like location, type and so on */
	symrec* get_symbol(char *symbol_name) {
		
	}

	/*
	typedef struct struct var_info {
		int offset;
		var_type type;
	} *var_info;
	*/

	/*
	 * stack - change stack size
	 */
	void stack(int size) {
		stacksize += size;
		if(stacksize < 0) {
			printf("warning: stack size cannot become negative\n");
		}
		if (stacksize > maxstacksize) {
			maxstacksize = stacksize;
		}
	}

	/*
	 * concat - concatenate s1+s2 and return result
	 * side-effect: malloc result, free s1+s2
	 */
	char *concat(char *s1, char *s2) {
		char *s;
		if (!s1) {
			return s2;
		}
		if (!s2) {
			return s1;
		}
		s = (char *)calloc(sizeof(char), strlen(s1) + strlen(s2) + 1);
		strcat(s, s1);
		strcat(s, s2);
		free(s1);
		free(s2);
		return s;
	}

	char *load(char *symbol_name) {
		symrec* symbol = get_symbol(symbol_name);
		switch(symbol->var_info.type) {
			case L:
				sprintf(t, "  lload %d ; load long %s \n", symbol->var_info.offset, symbol_name);
				break;
			case D:
				sprintf(t, "  dload %d ;load double %s \n", symbol->var_info.offset, symbol_name);
				break;
			case AL:
			case AD:
				sprintf(t, "  aload %d ; load array %s \n", symbol->var_info.offset, symbol_name);
				break;
			default:
				printf("error loading symbol");
				exit(0); 
		}
		return strdup(t);
	}

	/*
	 * return string "dstore <i>" for i-th variable "sym" in symbol table
	 */
	char *store(char *symbol_name) {
		symrec* symbol = get_symbol(symbol_name);
		switch(symbol->var_info.type) {
			case L:
				sprintf(t, "  lstore %d ;  storing %s var \n", symbol->var_info.offset, symbol_name);
				break;
			case D:
				sprintf(t, "  dstore %d ; storing %s var\n", symbol->var_info.offset, symbol_name);
				break;
			case AL:
			case AD:
				sprintf(t, "  astore %d; storing array %s\n", symbol->var_info.offset, symbol_name);
				break;
		}
		return strdup(t);
	}

%}


/* defintions: token, precedence, types etc. */

%start program

%union {
	char *str_ptr;
	long long_val;
	double double_val;
	var_info var_info;
	var_type var_type;
	symrec *table_ptr;
	/*Feel free to add any other data types*/
}

// terminal token declaration
%token ASSIGN VAR BEGINSYM END
%token THEN ENDIF
%token WHILE DO ENDWHILE
%token REPEAT UNTIL ENDREPEAT
%token FOR TO ENDFOR PARFOR ENDPARFOR
%token PRIVATE REDUCE
%token PROC ENDPROC PARPROC ENDPARPROC
%token WRITE READ
%token IN OUT INOUT REF
%token MIN MAX
%token INT REAL
%token LPAREN RPAREN
%token LBRACE RBRACE
%token COLON COMMA SEMICOLON
%token END_OF_FILE 

// type information for terminal tokens: identifiers and numbers
%token<table_ptr> IDENTIFIER    // TODO type should be of symbol
%token<double_val> REALNUMBER
%token<long_val> INTNUMBER

// type information for nonterminals
%type<str_ptr> program
%type<table_ptr> variable
%type<str_ptr> block
%type<str_ptr> declarations
%type<str_ptr> varListGroup	//
%type<table_ptr> varList		//
%type<str_ptr> variableGroup	//
%type<var_type> type
%type<var_type> basicType
%type<var_type> arrayType
%type<str_ptr> statement	//
%type<str_ptr> statementGroup
%type<table_ptr> assignment
%type<double_val> expression
%type<str_ptr> comparisonOp
%type<str_ptr> comparisonExpr  // maybe an long_val
%type<str_ptr> test
%type<str_ptr> loop
%type<str_ptr> whileLoop
%type<str_ptr> repeatLoop
%type<str_ptr> forLoop
%type<str_ptr> input
%type<str_ptr> output
%type<str_ptr> procedure
%type<str_ptr> parameters
%type<str_ptr> parametersOption
%type<str_ptr> parameterGroup
%type<str_ptr> parameter
%type<str_ptr> passBy

// associativity and precedence of operators
%right ASSIGN
%left AND
%left OR
%left NOT
%left GTE LTE EQ NEQ GT LT
%left MINUS PLUS 
%left MULT DIVIDE
%left DIV MOD
%nonassoc USIGN
%nonassoc IF
%nonassoc ELSE

%%

/***********************************************
 * Grammar Production Rules                    *
 ***********************************************/


program: 		block END_OF_FILE  {
				//fprintf(yyout, "  .limit stack %d ; so many items can be pushed\n", maxstacksize);
				//fprintf(yyout, "  .limit locals %d ; so many variables exist (doubles need 2 items)\n", maxsym + 1);
				//fprintf(yyout, "%s", $$);
				exit(0);
			}
			;
variable:		IDENTIFIER					{ $$ = get_symbol($1->symbol_name); }
			;
block:			declarations BEGINSYM statementGroup END	{}
			| BEGINSYM statementGroup END			{}
			;
statementGroup:		statementGroup statement
			| 						{}
			;
declarations:		VAR varListGroup				{}
			;
varListGroup:		varListGroup varList COLON type SEMICOLON
			|					{}
			;
varList: 		variable variableGroup
			;
variableGroup:		variableGroup COMMA variable
			| 								{ /* empty rule for typed nonterminal */ }				
			;
type:			basicType 
			| arrayType
			;
arrayType:		basicType LBRACE expression RBRACE				{ $$ = $1 == L ? AL : AD; }
			;
basicType:		INT								{ $$ = L; }
			| REAL								{ $$ = D; }
			;
statement:		assignment SEMICOLON				
			| block SEMICOLON 
			| test SEMICOLON 
			| loop SEMICOLON 
			| input SEMICOLON 
			| output SEMICOLON 
			| procedure SEMICOLON 
			| error SEMICOLON						{ /* empty rule for error production */ }
			;
assignment:		variable ASSIGN expression					
			| variable LBRACE expression RBRACE ASSIGN expression
			;
expression:		variable							{ symrec *variable_table_ptr = $1;
											  switch(variable_table_ptr->var_info.type) {
												case L: $$ = variable_table_ptr->value.long_val;
												case D: $$ = variable_table_ptr->value.double_val;
											  }
											}
			| variable LBRACE expression RBRACE 				// semantic use?
			| INTNUMBER							{ $$ = $1; }
			| REALNUMBER							{ $$ = $1; }
			| expression DIV expression					{ $$ = (div($1,$3)).quot; } 
			| expression MOD expression					{ $$ = (div($1,$3)).rem; }
			| expression DIVIDE expression					{ $$ = $1 / $3; }
			| expression MULT expression					{ $$ = $1 * $3; }
			| expression PLUS expression					{ $$ = $1 + $3; }
			| expression MINUS expression					{ $$ = $1 - $3; }
			| LPAREN expression RPAREN					{ $$ = $2; }
			| INT LPAREN expression RPAREN					{ $$ = round($3); }
			| PLUS expression %prec USIGN					{ $$ = $2; }
			| MINUS expression %prec USIGN					{ $$ = -$2; }
			;
comparisonOp:		EQ								{ $$ = "if_icmpeq"; }
			| NEQ								{ $$ = "if_icmpne"; }
			| LT								{ $$ = "if_icmplt"; }
			| GT								{ $$ = "if_icmpgt"; }
			| LTE								{ $$ = "if_icmple"; }
			| GTE								{ $$ = "if_icmpge"; }
			;
comparisonExpr:		expression comparisonOp expression	{return 1; /* TODO */}
			| comparisonExpr AND comparisonExpr
			| comparisonExpr OR comparisonExpr
			| NOT comparisonExpr			{return 0; /* TODO */}
			;
test:			IF comparisonExpr THEN statementGroup ENDIF
			| IF comparisonExpr THEN statementGroup ELSE statementGroup ENDIF
			;
loop:			whileLoop
			| repeatLoop
			| forLoop
			;
whileLoop:		WHILE comparisonExpr DO statementGroup ENDWHILE 	{
										sprintf(go_l1, "  ifne Label%d\n", label);
										sprintf(l1, "Label%d:\n", label++);
										sprintf(goto_l2, "  goto Label%d\n", label);
										sprintf(l2, "Label%d:\n", label++);
										$$ = concat(
										       concat(
											 concat(
											   concat(
											     concat(
											       strdup(goto_l2),
												 strdup(l1)),
											       $4),
											     strdup(l2)),
											   $2),
										  strdup(go_l1));
										stack(-1);
										}
			;
repeatLoop:		REPEAT statementGroup UNTIL comparisonExpr ENDREPEAT
			;
forLoop:		FOR variable ASSIGN expression TO expression DO statementGroup ENDFOR
			;
/*
parforLoop:		PARFOR variable ASSIGN expression TO expression parMod DO statementGroup ENDPARFOR
			;

parMod:			reduceGroup
			| PRIVATE varList reduceGroup
			;
reduceGroup:		reduceGroup REDUCE reduceOp varList
			|
			;
reduceOp:		MINUS				{}
			|PLUS				{}
			| MIN				{}
			| MAX				{}
			;
*/
input:			READ LPAREN IDENTIFIER RPAREN {
				symrec* read_symbol = get_symbol($3->symbol_name);
				struct var_info read_symbol_info = read_symbol->var_info;
				stack(+2);
				if(read_symbol_info.type == D) { 	
					$$ = concat(
					strdup("  invokestatic Keyboard/readDouble()D\n"),
					strdup(store($3->symbol_name)));
				} else if(read_symbol_info.type == L) {
					$$ = concat(
					strdup("  invokestatic Keyboard/readInt()I\n  i2l\n"),
					strdup(store($3->symbol_name)));
				} else {
					yyerror("cannot read arrays\n");
					exit(1);
				}
				stack(-2);
			}
			;

//should output have an expression?
output:			WRITE LPAREN expression RPAREN
			;
procedure:		PROC IDENTIFIER LPAREN parametersOption RPAREN block ENDPROC
			| PARPROC IDENTIFIER LPAREN parametersOption RPAREN block ENDPARPROC
			;
parameters:		parameter parameterGroup
			;
parametersOption:	parameters
			|
			;
parameterGroup:		parameterGroup COMMA parameter
			| 					{ /* empty rule for typed nonterminal */ }
			;
parameter:		passBy variable COLON type
			;
passBy:			IN
			| OUT
			| INOUT
			| REF
			;
/*
procCall:		variable LPAREN arguments RPAREN
			;
arguments:		expression expressionGroup
			|
			;

expressionGroup:	expressionGroup COMMA expression
			| 
			;
*/

%%

/***********************************************
 * subroutines                                 *
 ***********************************************/

#include "pseudo.yy.c"

/*
* use - how to use program (exit)
*/
void use() {
	fprintf(stderr, "use: pseudo [fn.psd]\n");
	exit(0);
}

int main(int argc, char *argv[]) {
	// much more than just return yyparse();
	
//	return yyparse();

	int result;
	char *basename;
	char *pos = NULL;

	if (argc > 2) {
		use();
	}

	if (argc == 2) {
		basename = strdup(argv[1]);
		pos = (char *) rindex(basename, '.');
		if (pos) {
			*pos = '\0';
		} else {
			fprintf(stderr, "no file extension found\n");
			use();
		}

		if ((yyin = (FILE *) fopen(argv[1], "r")) == NULL) {
			fprintf(stderr, "cannot open input file %s\n", argv[1]);
			use();
		}

		if ((yyout = (FILE *) fopen(strcat(basename, ".jas"), "w")) == NULL) {
			fprintf(stderr, "cannot open output file %s\n", basename);
			use();
		}

		*pos = '\0';
	} else {
		basename = strdup("main");
	}

	fprintf(yyout, ".source %s.psd\n", basename);
	fprintf(yyout, ".class public %s\n", basename);
	fprintf(yyout, ".super java/lang/Object\n");
	fprintf(yyout, "\n");
	fprintf(yyout, ";\n");
	fprintf(yyout, "; standard initializer (calls java.lang.Object's initializer)\n");
	fprintf(yyout, ";\n");
	fprintf(yyout, ".method public <init>()V\n");
	fprintf(yyout, "   aload_0\n");
	fprintf(yyout, "   invokenonvirtual java/lang/Object/<init>()V\n");
	fprintf(yyout, "   return\n");
	fprintf(yyout, ".end method\n");
	fprintf(yyout, "\n");
	fprintf(yyout, ";\n");
	fprintf(yyout, "; main() -\n");
	fprintf(yyout, ";\n");
	fprintf(yyout, ".method public static main([Ljava/lang/String;)V\n");

	result = (int) yyparse();

	fprintf(yyout, "\n");
	fprintf(yyout, "   ; done\n");
	fprintf(yyout, "   return\n");
	fprintf(yyout, ".end method\n");

}

/*
 * yyerror - returns error msg "err" and line number
 */
yyerror(char *s) {
	fprintf(stderr, "line %d: illegal character (%s)\n", yylineno, yytext);
	//fprintf(stderr, "%s in line %d at %s\n", err, yylineno, yytext);
}

