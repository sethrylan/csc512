#include <stdio.h>
#include "calc3.h"
#include "y.tab.h"

static int lbl;

int ex(node *p) {
	int lbl1, lbl2;
	if (!p) {
		return 0;
	}
	switch(p->node_type) {
		case CONSTANT_TYPE:	  
			printf("\tpush(%d);\n", p->constant.value);
			break;
		case IDENTIFIER_TYPE:
			printf("\tpush(%s);\n", p->identifier.symbol_name);
			break;
		case OPERATOR_TYPE:
			switch(p->oper.operation) {
				case WHILE:
					printf("L%03d:\n", lbl1 = lbl++);
					ex(p->oper.op[0]);
					printf("\tif(!pop())\n");
					printf("\t\tgoto\tL%03d;\n", lbl2 = lbl++);
					ex(p->oper.op[1]);
					printf("\tgoto\tL%03d;\n", lbl1);
					printf("L%03d:\n", lbl2);
					break;
				case IF:
					ex(p->oper.op[0]);
					if (p->oper.nops > 2) {
						/* if else */
						printf("\tif (!pop())\n");
						printf("\t\tgoto L%03d;\n", lbl1 = lbl++);
						ex(p->oper.op[1]);
						printf("\tgoto\tL%03d;\n", lbl2 = lbl++);
						printf("L%03d:\n", lbl1);
						ex(p->oper.op[2]);
						printf("L%03d:\n", lbl2);
					} else {
						/* if */
						printf("\tif (!pop())\n");
						printf("\tgoto\tL%03d;\n", lbl1 = lbl++);
						ex(p->oper.op[1]);
						printf("L%03d:\n", lbl1);
					}
					break;
				case PRINT:	
					ex(p->oper.op[0]);
					printf("\tprint();\n");
					break;
				case ASSIGN:	  
					ex(p->oper.op[1]);
					printf("\t%s = pop();\n", p->oper.op[0]->identifier.symbol_name);
					break;
				case UMINUS:
					ex(p->oper.op[0]);
					printf("\tneg();\n");
					break;
				/*
				case FACT:
			  		ex(p->oper.op[0]);
					printf("\tfact();\n");
					break;
				case LNTWO:
					ex(p->oper.op[0]);
					printf("\tlntwo();\n");
					break;
				*/
				default:
					ex(p->oper.op[0]);
					ex(p->oper.op[1]);
					switch(p->oper.operation) {
						/*
						case GCD:  
						printf("\tgcd();\n");
						break;
						*/
						case SEMICOLON:
							return 0;
							break;
						case PLUS:
							printf("\tadd();\n");
							break;
						case MINUS:
							printf("\tsub();\n");
							break; 	
						case MULT:
							printf("\tmul();\n");
							break;
						case DIVIDE:
							printf("\tdiv();\n");
							break;
						case LT:
							printf("\tLESS();\n"); 
							return 0;
						case GT:  
							printf("\tGREATER();\n"); 
							return 0;
						case GTE:
							printf("\tGE();\n"); 
							return 0;
						case LTE: 
							printf("\tLE();\n"); 
							return 0;
						case NEQ:	
							printf("\tNE();\n"); 
							return 0;
						case EQ:	
							printf("\tEQ();\n"); 
							return 0;
						default:
							printf("/*unknown operator: %d*/\n", p->oper.operation);
							return 0;
					} // end (p->oper.oper) 
			} // end switch(p->oper.oper)
	} // end switch(p->node_type)
	return 0;
}
