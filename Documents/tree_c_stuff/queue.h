#ifndef CANDICE
#define CANDICE

#include "treetest.h"

typedef struct q_node{
	void* data; //can store any type (i.e. node_t)
	struct q_node* next;
	struct q_node* prev;

	int visited;
}q_node_t;

typedef struct queue{
	q_node_t* front;
	q_node_t* rear;

	int count;
}queue_t;

q_node_t* q_node_init(void* data);
void queue_init(queue_t* q);

int isEmpty(queue_t* q);

q_node_t* dequeue(queue_t* q);
void enqueue(queue_t* q, q_node_t* n);

void free_queue(queue_t* q);
void print_queue(queue_t* q);

#endif
