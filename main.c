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

extern int   _add(int, int);	

extern void  _cvec_init			(c_vector* vec, int dataSize);
extern void  _cvec_copy			(c_vector* vecF, c_vector* vecS);

extern int   _cvec_size			(c_vector* vec);
extern int   _cvec_capacity		(c_vector* vec);

extern void  _cvec_resize		(c_vector* vec, int newCap); 
extern void  _cvec_clear		(c_vector* vec); 

extern void  _cvec_set			(c_vector* vec, int index, void* data);
extern void* _cvec_get			(c_vector* vec, int index);

extern void  _cvec_push_back	(c_vector* vec, void* data);
extern void* _cvec_pop_back		(c_vector* vec);
extern void	 _cvec_del_el		(c_vector* vec, int index);// not work !!!QUESION!!!

int main(void)
{
  c_vector Tvec;
  int a = 10, b = 143;

  printf("start\n");

  _cvec_init(&Tvec, sizeof(int));

  printf("data = %d\t capacity is %d\t size = %d\t element_size %d\t\n", Tvec.data, Tvec.capacity, Tvec.size, Tvec.element_size);
  
  _cvec_resize(&Tvec, 57);

  for (int i = 0; i < 100; ++i)
		_cvec_push_back(&Tvec, &i);
  
  _cvec_resize(&Tvec, 1000);
  
  _cvec_push_back(&Tvec, &b);
  
  _cvec_set(&Tvec, 211, &b);

  printf("Tvec:\t S vec is %d\t C vec is %d\t vec[x] %d\t\n", _cvec_size(&Tvec), _cvec_capacity(&Tvec), *(int*)_cvec_get(&Tvec, 100));

  c_vector TTvec;
  _cvec_init(&TTvec, sizeof(int));
  _cvec_copy(&TTvec, &Tvec);

  _cvec_del_el(&TTvec, 5);
  printf("TTvec:\t Data = %d\t cap is %d\t size is %d\t vec_T[x] is %d\t\n", TTvec.data, _cvec_capacity(&TTvec), _cvec_size(&TTvec), *(int*)_cvec_get(&TTvec, 5));

  _cvec_clear(&Tvec);
  printf("end\n");
  return 0;
}
