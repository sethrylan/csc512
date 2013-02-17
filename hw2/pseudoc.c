/********************************************

Java Bytecode: 		http://en.wikipedia.org/wiki/Java_bytecode_instruction_listings
More Bytecode:		http://en.wikibooks.org/wiki/Java_Programming/Byte_Code

Jasmin lesson:		http://www.cse.chalmers.se/edu/year/2012/course/TDA282/lect02-2x2.pdf
Jasmin lesson (inc arrays): http://www.csc.villanova.edu/~tway/courses/csc8505/s2011/handouts/JVM%20and%20Jasmin.pdf
Jasmin Compiler example:	http://files.dbruhn.de/compilerpraktikum/src/edu/kit/compilerpraktikum/bytecode/InsanelyFastByteCodeCreator.java
********************************************/
#include <stdio.h>
#include "pseudo.h"
#include "pseudo.tab.h"			// bison -d generated header

extern FILE *yyout;

static int lbl;

int ex(node *p) {
	int lbl1, lbl2;
	if (!p) {
		return 0;
	}
	switch(p->node_type) {
		case CONSTANT_TYPE:	  
			fprintf(yyout, "\tpush(%d);\n", p->constant.value);
			break;
		case IDENTIFIER_TYPE:
			fprintf(yyout, "\tpush(%s);\n", p->identifier.symbol_name);
			break;
		case OPERATOR_TYPE:
			switch(p->oper.operation) {
				case PROGRAM:
					fprintf(yyout, ".source %s.psd\n", input_file_basename);
					fprintf(yyout, ".class public %s\n", input_file_basename);
					fprintf(yyout, ".super java/lang/Object\n");
					fprintf(yyout, ";\n");
					fprintf(yyout, "; standard initializer (calls java.lang.Object's initializer)\n");
					fprintf(yyout, ";\n");
					fprintf(yyout, ".method public <init>()V\n");
					fprintf(yyout, "	aload_0\n");
					fprintf(yyout, "	invokenonvirtual java/lang/Object/<init>()V\n");
					fprintf(yyout, "	return\n");
					fprintf(yyout, ".end method\n");
					fprintf(yyout, ";\n");
					fprintf(yyout, "; main()\n");
					fprintf(yyout, ";\n");
					fprintf(yyout, ".method public static main([Ljava/lang/String;)V\n");
					ex(p->oper.op[0]);
					fprintf(yyout, "	; done\n");
					fprintf(yyout, "	return\n");
					fprintf(yyout, ".end method\n");
					break;
				case WHILE:
					fprintf(yyout, "L%03d:\n", lbl1 = lbl++);
					ex(p->oper.op[0]);
					fprintf(yyout, "\tif(!pop())\n");
					fprintf(yyout, "\t\tgoto\tL%03d;\n", lbl2 = lbl++);
					ex(p->oper.op[1]);
					fprintf(yyout, "\tgoto\tL%03d;\n", lbl1);
					fprintf(yyout, "L%03d:\n", lbl2);
					break;
				case IF:
					ex(p->oper.op[0]);
					if (p->oper.nops > 2) {
						/* IF ELSE */
						fprintf(yyout, "\tif (!pop())\n");
						fprintf(yyout, "\t\tgoto L%03d;\n", lbl1 = lbl++);
						ex(p->oper.op[1]);
						fprintf(yyout, "\tgoto\tL%03d;\n", lbl2 = lbl++);
						fprintf(yyout, "L%03d:\n", lbl1);
						ex(p->oper.op[2]);
						fprintf(yyout, "L%03d:\n", lbl2);
					} else {
						/* IF */
						fprintf(yyout, "\tif (!pop())\n");
						fprintf(yyout, "\tgoto\tL%03d;\n", lbl1 = lbl++);
						ex(p->oper.op[1]);
						fprintf(yyout, "L%03d:\n", lbl1);
					}
					break;
				case WRITE:	
					ex(p->oper.op[0]);
					fprintf(yyout, "\tprint();\n");
					break;
				case READ:
					ex(p->oper.op[0]);
					//TODO
					break;
				case ASSIGN:	  
					ex(p->oper.op[1]);
					fprintf(yyout, "\t%s = pop();\n", p->oper.op[0]->identifier.symbol_name);
					break;
				case UMINUS:
					ex(p->oper.op[0]);
					fprintf(yyout, "\tneg();\n");
					break;
				default:
					ex(p->oper.op[0]);
					ex(p->oper.op[1]);
					switch(p->oper.operation) {
						case SEMICOLON:
							/* END OF LINE */
							return 0;
							break;
						case PLUS:
							fprintf(yyout, "\tadd();\n");
							break;
						case MINUS:
							fprintf(yyout, "\tsub();\n");
							break; 	
						case MULT:
							fprintf(yyout, "\tmul();\n");
							break;
						case DIVIDE:
							fprintf(yyout, "\tdiv();\n");
							break;
						case LT:
							fprintf(yyout, "\tLESS();\n"); 
							return 0;
						case GT:  
							fprintf(yyout, "\tGREATER();\n"); 
							return 0;
						case GTE:
							fprintf(yyout, "\tGE();\n"); 
							return 0;
						case LTE: 
							fprintf(yyout, "\tLE();\n"); 
							return 0;
						case NEQ:	
							fprintf(yyout, "\tNE();\n"); 
							return 0;
						case EQ:	
							fprintf(yyout, "\tEQ();\n"); 
							return 0;
						default:
							fprintf(yyout, "/*unknown operator: %d*/\n", p->oper.operation);
							return 0;
					} // end (p->oper.oper) 
			} // end switch(p->oper.oper)
	} // end switch(p->node_type)
	return 0;
}
