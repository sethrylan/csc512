

typedef enum { CONSTANT_TYPE, IDENTIFIER_TYPE, OPERATOR_TYPE } node_type_enum;

/***** Constant Type *****/
typedef struct {
	int value;			/* value of constant */
} constant_node;

/***** Identifier Type *****/
typedef struct {
	char* symbol_name;		/* subscript to sym array; aka, name of symbol */
} identifier_node;

/***** Operator Type *****/
typedef struct {
	int operation;			/* operator */
	int nops;			/* number of operands */
	struct node_tag *op[1];		/* operands (expandable) */
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

extern int sym[26];
extern char *input_file_basename;

