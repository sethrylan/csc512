
%{
	#include <stdio.h>

	extern FILE *yyin;
	extern FILE *yyout;

	extern int yylineno;
	extern char *yytext;

	int yylex(void);
	int iVerbose = 1;

	int label = 0;
	int maxstacksize = 0;
	int stacksize = 0;

	char s[1024], t[1024];
	char l1[1024], go_l1[1024];
	char l2[1024], goto_l2[1024];

	typedef enum  {
		L = 0,  /*long*/
		D = 1,  /*double*/
		AL = 2, /*long array*/
		AD = 3  /*double array*/
	} var_type;

	typedef struct syment_s {
		char *s;
		int offset;
		var_type type;
		struct syment_s *next;
	} *syment;

	typedef struct Scope{
		syment sym_table;
		struct Scope* parent;
	} *Scope;





	struct var_info {
		int offset;
		var_type type;
	};

	typedef struct var_info var_info;

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
		s = (char *) calloc(sizeof(char), strlen(s1) + strlen(s2) + 1);
		strcat(s, s1);
		strcat(s, s2);
		free(s1);
		free(s2);
		return s;
	}


	char *load(char *sym) {
		var_info info = getsym(sym);
  
		switch(info.type) {
			case L:
				sprintf(t, "  lload %d ; load long %s \n", info.offset, sym);
				break;
			case D:
				sprintf(t, "  dload %d ;load double %s \n", info.offset, sym);
				break;
			case AL:
			case AD:
				sprintf(t, "  aload %d ; load array %s \n",info.offset, sym);
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
	char *store(char *sym) {
		var_info info;
		info = getsym(sym);

		switch(info.type) {
			case L:
				sprintf(t,"  lstore %d ;  storing %s var \n",info.offset,sym);
				break;
			case D:
				sprintf(t,"  dstore %d ; storing %s var\n",info.offset,sym);
				break;
			case AL:
			case AD:
				sprintf(t,"  astore %d; storing array %s\n",info.offset,sym);
				break;
		}
		return strdup(t);
	}

	void beginScope();
	void endScope();

	/* returns stack location for variable s*/
	int addSymbol(char *s, var_type type);
	/*rteurn metadata for symbol s like location, type and so on*/
	struct var_info getsym(char *s);
%}


/***********************************************
 * defintions: token, precedence, types etc.   *
 ***********************************************/

//%start program

%union {
	char *str_ptr;
	int int_val;
	double double_val;
	/*Feel free to add any other data types*/
}

%token BEGIN_K END END_OF_FILE
%token DO WHILE ENDWHILE
%token INT REAL
%token LPAREN RPAREN
%token<str_ptr> ID 
%token READ

%token compExp
%token declarations
%token statements

%type<int_val> compExp
%type<int_val> block

%type<int_val> program
%type<str_ptr> input
%type<var_type> basicType
%type<str_ptr> statements
%type<str_ptr> whileLoop

%%

/***********************************************
 * Grammar Production Rules                    *
 ***********************************************/

program : block END_OF_FILE {
		fprintf(yyout, "  .limit stack %d ; so many items can be pushed\n", maxstacksize);
		fprintf(yyout, "  .limit locals %d ; so many variables exist (doubles need 2 items)\n", maxsym + 1);
		fprintf(yyout, "%s", $$);
		//exit(0);
	}
	;

// added
variable:		ID				{}
			;
block:			declarations BEGIN_K statements END
			| BEGIN_K statements END
			;


basicType : INT {
		$$ = L;
	} 
	| REAL {
		$$ = D;
	}
	;

input : READ LPAREN ID RPAREN {
		struct var_info readId = getsym($3);
		stack(+2);
		if(readId.type == D) { 	
			$$ = concat(
			strdup("  invokestatic Keyboard/readDouble()D\n"),
			strdup(store($3)));
		} else if(readId.type == L) {
			$$ = concat(
			strdup("  invokestatic Keyboard/readInt()I\n  i2l\n"),
			strdup(store($3)));
		} else {
			yyerror("cannot read arrays\n");exit(1);
		}
		stack(-2);
	}
	;

whileLoop : WHILE compExp DO statements ENDWHILE {
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
%%

/***********************************************
 * subroutines                                 *
 ***********************************************/

/*
* use - how to use program (exit)
*/
void use() {
	fprintf(stderr, "use: pseudo [fn.psd]\n");
	exit(0);
}

int main(int argc, char *argv[]) {
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

yyerror(char *s) {
	fprintf(stderr, "line %d: illegal character (%s)\n", yylineno, yytext);
}

