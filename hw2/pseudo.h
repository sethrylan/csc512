

typedef enum {
	CONSTANT_TYPE, 
	IDENTIFIER_TYPE, 
	OPERATOR_TYPE 
} node_type_enum;

typedef enum  {
	L = 0,  /*long*/
	D = 1,  /*double*/
	AL = 2, /*long array*/
	AD = 3  /*double array*/
} var_type;

/***** Constant Type *****/
typedef struct {
	int value;					/* value of constant */
} constant_node;

/***** Identifier Type *****/
typedef struct {
	char* symbol_name;				/* subscript to sym array; aka, name of symbol */
} identifier_node;

/***** Operator Type *****/
typedef struct {
	int operation;					/* operator */
	int nops;					/* number of operands */
	struct node_tag *operands[1];			/* operands (expandable) */
} operator_node;

typedef struct node_tag {
	node_type_enum node_type;			/* type of node */

	/***** union must be last entry in nodeType, because operator_node may dynamically increase *****/
	union {
		constant_node constant;			/* constants */
		identifier_node identifier;		/* identifiers */
		operator_node oper;			/* operators */
	};
} node;

extern int symbol_table[26];
extern char *input_file_basename;
extern int maxstacksize, maxsymbols;

