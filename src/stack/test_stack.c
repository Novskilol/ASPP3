/* test_stack.c */

#include "stack.h"
#include "stdio.h"

int main (int argc, char* argv[]) 
{
  Stack p=stack_create();
  int a=1, b=2, c=3;
  printf("push %d\n", a);
  stack_push(p, &a);
  printf("push %d\n", b);
  stack_push(p, &b);
  printf("push %d\n", c);
  stack_push(p, &c);

  void * top = stack_top(p);
  printf("top = %d\n", *((int*)top));
  stack_pop(p);
  printf("pop\n");
    stack_pop(p);
  printf("pop\n");
  
  top = stack_top(p);
  printf("top = %d\n", *((int*)top));
  stack_pop(p);
  printf("pop\n");
  stack_destroy(p);

  return 0;  
}
