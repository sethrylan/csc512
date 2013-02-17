/********************************************

Java Bytecode: 		http://en.wikipedia.org/wiki/Java_bytecode_instruction_listings
More Bytecode:		http://en.wikibooks.org/wiki/Java_Programming/Byte_Code
As a list:		http://borneq.com/JavaByteCodes.txt

Jasmin lesson:			http://www.cse.chalmers.se/edu/year/2012/course/TDA282/lect02-2x2.pdf
Jasmin lesson (inc arrays): 	http://www.csc.villanova.edu/~tway/courses/csc8505/s2011/handouts/JVM%20and%20Jasmin.pdf
Jasmin Compiler example:	http://files.dbruhn.de/compilerpraktikum/src/edu/kit/compilerpraktikum/bytecode/InsanelyFastByteCodeCreator.java

Many Jasmin examples: http://www.cs.sjsu.edu/~pearce/modules/lectures/co/jvm/jasmin/demos/demos.html
Jasmin Instructions: http://jasmin.sourceforge.net/instructions.html

********************************************/
#include <stdio.h>
#include "pseudo.h"
#include "pseudo.tab.h"			// bison -d generated header

extern FILE *yyout;

static int lbl;

int assemble(node *p) {
	int label_1, label_2;
	label_1 = lbl++;
	label_2 = lbl++;
	if (!p) {
		return 0;
	}
	switch(p->node_type) {
		case CONSTANT_TYPE:
			fprintf(yyout, "	ldc %d\n", p->constant.value);			// push a constant on the stack
			break;
		case IDENTIFIER_TYPE:
			//printf("IDENTIFIER_TYPE---\n");
			fprintf(yyout, "\tpush(%s);\n", p->identifier.symbol_name);
			//printf("----IDENTIFIER_TYPE\n");
			break;
		case OPERATOR_TYPE:
			switch(p->oper.operation) {
				case PROGRAM:
					lbl = 1;
					fprintf(yyout, ".source %s.psd \n", input_file_basename);		// add boilerplate directives
					fprintf(yyout, ".class public %s \n", input_file_basename);
					fprintf(yyout, ".super java/lang/Object \n");
					fprintf(yyout, "; \n");
					fprintf(yyout, "; standard initializer (calls java.lang.Object's initializer) \n");
					fprintf(yyout, "; \n");
					fprintf(yyout, ".method public <init>()V \n");
					fprintf(yyout, "	aload_0 \n");
					fprintf(yyout, "	invokenonvirtual java/lang/Object/<init>()V \n"); // or invokespecial? see // source: http://www.ceng.metu.edu.tr/courses/ceng444/link/f3jasmintutorial.html
					fprintf(yyout, "	return \n");
					fprintf(yyout, ".end method \n");
					fprintf(yyout, "; \n");
					fprintf(yyout, "; main() \n");
					fprintf(yyout, "; \n");
					//fprintf(yyout, "; PROGRAM --- \n");
					assemble(p->oper.operands[0]);						// assemble BLOCK
					//fprintf(yyout, "; ---- PROGRAM\n");
					break;
				case BLOCK:
					fprintf(yyout, ".method public static main([Ljava/lang/String;)V \n");
					fprintf(yyout, "	.limit stack %d \n", maxstacksize);		// Sets the maximum size of the operand stack required by the method
					fprintf(yyout, "	.limit locals %d \n", maxsymbols + 1);		// Sets the number of local variables required by the method
					if (p->oper.nops == 2) {						// declarations here
						assemble(p->oper.operands[1]);
					} 
					//fprintf(yyout, "; BLOCK---\n");
					assemble(p->oper.operands[0]);						// assemble statements
					//fprintf(yyout, "; ---- BLOCK\n");
					fprintf(yyout, "	; done \n");
					fprintf(yyout, "	return \n");
					fprintf(yyout, ".end method \n");
					break;
				case DECLARATIONS:
					//printf("DECLARATIONS---\n");
					assemble(p->oper.operands[0]);
					//printf("---DECLARATIONS\n");
					break;
				case VARIABLELISTGROUP:				// operand[0] is an IDENTIFIER; operand[1] is a BASICTYPE/ARRAYTYPE nodes
					//printf("VARIABLELISTGROUP\n");
					//TODO: add_sym_to_table
					assemble(p->oper.operands[0]);
					fprintf(yyout, "	ldc 0 \n");			// initialize to 0
					fprintf(yyout, "	istore 1 \n");			// store in local variable n
					assemble(p->oper.operands[1]);
					break;
				case WHILE:
					fprintf(yyout, "L%03d:\n", label_1);
					assemble(p->oper.operands[0]);
					fprintf(yyout, "\tif(!pop())\n");
					fprintf(yyout, "\t\tgoto\tL%03d;\n", label_2);
					assemble(p->oper.operands[1]);
					fprintf(yyout, "\tgoto\tL%03d;\n", label_1);
					fprintf(yyout, "L%03d:\n", label_2);
					break;
				case IF:
					assemble(p->oper.operands[0]);
					if (p->oper.nops > 2) {
						/* IF ELSE */
						fprintf(yyout, "\tif (!pop())\n");
						fprintf(yyout, "\t\tgoto L%03d;\n", label_1);
						assemble(p->oper.operands[1]);
						fprintf(yyout, "\tgoto\tL%03d;\n", label_2);
						fprintf(yyout, "L%03d:\n", label_1);
						assemble(p->oper.operands[2]);
						fprintf(yyout, "L%03d:\n", label_2);
					} else {
						/* IF */
						fprintf(yyout, "\tif (!pop()) \n");
						fprintf(yyout, "\tgoto\tL%03d; \n", label_1);
						assemble(p->oper.operands[1]);
						fprintf(yyout, "L%03d:\n", label_1);
					}
					break;
				case WRITE:
					/* Write Constant Integer */
					fprintf(yyout, "	getstatic java/lang/System/out Ljava/io/PrintStream; \n");
					assemble(p->oper.operands[0]);
					fprintf(yyout, "	invokevirtual java/io/PrintStream/println(I)V \n");

					/* Write Float */
					/*
					    fload 0 
					    getstatic java/lang/System/out Ljava/io/PrintStream; 
					    swap 
					    invokevirtual java/io/PrintStream/print(F)V 
					*/

					/* Write Integer */
					/*
					    iload 0 
					    getstatic java/lang/System/out Ljava/io/PrintStream; 
					    swap 
					    invokevirtual java/io/PrintStream/print(I)V 
					*/

					break;
				case READ:
					/*  Read an integer  */
					fprintf(yyout, "	ldc 0 \n");
					fprintf(yyout, "	istore %d \n", 555);	// TODO: 555 is placehold index for what will later use symboltable; this will hold our final integer
					fprintf(yyout, " Label%d: \n", label_1);
					fprintf(yyout, "	getstatic java/lang/System/in Ljava/io/InputStream; \n");
					fprintf(yyout, "	invokevirtual java/io/InputStream/read()I \n");
					fprintf(yyout, "	istore %d \n", 555 + 1);
					fprintf(yyout, "	iload %d \n", 555 + 1);
					fprintf(yyout, "	ldc 10 \n");			// newline
					fprintf(yyout, "	isub \n");
					fprintf(yyout, "	ifeq Label%d \n", label_2);
					fprintf(yyout, "	iload %d \n", 555 + 1);
					fprintf(yyout, "	ldc 32 \n");			// space
					fprintf(yyout, "	isub \n");
					fprintf(yyout, "	ifeq Label%d \n", label_2);
					fprintf(yyout, "	iload %d \n", 555 + 1);
					fprintf(yyout, "	ldc 48 \n");			// now subtract digit from 48 for integer value 
					fprintf(yyout, "	isub \n");
					fprintf(yyout, "	ldc 10 \n");
					fprintf(yyout, "	iload %d \n", 555);
					fprintf(yyout, "	imul \n");
					fprintf(yyout, "	iadd \n"); 
					fprintf(yyout, "	istore %d \n", 555);
					fprintf(yyout, "	goto Label%d \n", label_1);
					fprintf(yyout, " Label%d:\n", label_2);          		// local variable #store_index now contains read integer
					fprintf(yyout, "	iload %d \n", 555);		// read function ends here with result loaded to stack
					fprintf(yyout, "	istore ");			//TODO: assign
					assemble(p->oper.operands[0]);
					fprintf(yyout, " \n");

					break;
				case ASSIGN:	  
					assemble(p->oper.operands[1]);
					fprintf(yyout, "	istore %s \n", p->oper.operands[0]->identifier.symbol_name);
					break;
				case UMINUS:
					assemble(p->oper.operands[0]);
					fprintf(yyout, "\tneg(); \n");
					break;
				default:
					assemble(p->oper.operands[0]);
					assemble(p->oper.operands[1]);
					switch(p->oper.operation) {
						case SEMICOLON:
							/* END OF LINE */
							return 0;
							break;
						case PLUS:
							fprintf(yyout, "	iadd \n");
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
							fprintf(yyout, "	; unknown operator: %d \n", p->oper.operation);
							return 0;
					} // end (p->oper.oper) 
			} // end switch(p->oper.oper)
	} // end switch(p->node_type)
	return 0;
}

