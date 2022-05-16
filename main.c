#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>  
#include <string.h>

#define C_VEC_STANDART_CAP 6

typedef struct {
	void* data;
	int element_size;

	int size;
	int capacity;
	int test;
} c_vector;

bool IsFull(c_vector* vec) 
{
	return vec->capacity == vec->size;
}

void CopyFor(c_vector* vec, int index)
{
	for (int i = index; (i + 1) < vec->size; ++i)
	{
		void* current = (char*)vec->data + (i * vec->element_size);
		void* next = (char*)vec->data + ((i + 1) * vec->element_size);
		memcpy(current, next, vec->element_size);
	}
}

void DoubleCap(c_vector* vec) { _cvec_resize(vec, vec->capacity * 2); }

void cvec_push_back(c_vector* vec, void* data)
{
	if (IsFull(vec))
		DoubleCap(vec);

	void* place = (char*)vec->data + (vec->size * vec->element_size);
	memcpy(place, data, vec->element_size);

	++vec->size;
}

void cvec_resize(c_vector* vec, int newCap)
{
	vec->capacity = newCap;

	void* t = malloc(vec->element_size * vec->capacity);
	memcpy(t, vec->data, vec->element_size * vec->size);

	free(vec->data);
	vec->data = t;
}
extern int _add(int, int);	

extern void _cvec_init			(c_vector* vec, int dataSize); 

extern void _cvec_resize		(c_vector* vec, int newCap); 
extern void _cvec_clear			(c_vector* vec); // not work

extern void _cvec_set			(c_vector* vec, int index, void* data);
extern void* _cvec_get			(c_vector* vec, int index);

extern void* _cvec_pop_back		(c_vector* vec);

extern int _cvec_size			(c_vector* vec);
extern int _cvec_capacity		(c_vector* vec);



int main(void)
{
  c_vector Tvec;
  int a = 10, b = 5;

  printf("start\n");

  _cvec_init(&Tvec, sizeof(int));

  printf("data = %d\t capacity is %d\t size = %d\t element_size %d\t\n", Tvec.data, Tvec.capacity, Tvec.size, Tvec.element_size);
  
  _cvec_resize(&Tvec, 57);

  for (int i = 0; i < 100; ++i)
		cvec_push_back(&Tvec, &i);

  int i = _add(a, b);
  int s = _cvec_size(&Tvec);
  
  _cvec_resize(&Tvec, 1000);

  int c = _cvec_capacity(&Tvec);
  
  _cvec_set(&Tvec, 211, &b);

  printf("a/b = %d\t S vec is %d\t C vec is %d\t vec[x] %d\t\n", i, s, c, *(int*)_cvec_get(&Tvec, 211));
  
  printf("end\n");
  return 0;
}
