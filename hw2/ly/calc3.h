

typedef enum { CONSTANT_TYPE, IDENTIFIER_TYPE, OPERATOR_TYPE } node_type_enum;

/* constants */
typedef struct {
	int value;			/* value of constant */
} constant_node;

/* identifiers */
typedef struct {
	char* symbol_name;		/* subscript to sym array; aka, name of symbol */
} identifier_node;

/* operators */
typedef struct {
	int operation;			/* operator */
	int nops;			/* number of operands */
	struct node_tag *op[1];		/* operands (expandable) */
} operator_node;

typedef struct node_tag {
	node_type_enum node_type;			/* type of node */

	/* union must be last entry in nodeType */
	/* because operNodeType may dynamically increase */
	union {
		constant_node constant;			/* constants */
		identifier_node identifier;		/* identifiers */
		operator_node oper;			/* operators */
	};
} node;

extern int sym[26];
