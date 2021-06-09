#ifndef PEN_ISLAND
#define PEN_ISLAND

typedef struct node{
        int value;
	int visited;

        struct node* leftNode;
        struct node* rightNode;
} node_t;

typedef struct tree{
        struct node* root;
        int count;
} tree_t;

int add(node_t* n, node_t** tn);
void print_tree(node_t* tn);
node_t* node_init(int val);
void tree_init(tree_t* t1);
int pop_random(node_t** tn, int num);
void free_tree(node_t** tn);
void bfs(node_t* tn);

#endif
