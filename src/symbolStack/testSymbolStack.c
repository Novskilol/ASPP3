
/* test_stack.c */

#include "symbolStack.h"
#include "stdio.h"

int main (int argc, char* argv[]) 
{
  SymboleStack p=createSymboleStack();
  int a=1, b=2, c=3;
  printf("push %d\n", a);
  pushSymboleStack(p, &a);
  printf("push %d\n", b);
  pushSymboleStack(p, &b);
  printf("push %d\n", c);
  pushSymboleStack(p, &c);

  void * top = topSymboleStack(p);
  printf("top = %d\n", *((int*)top));
  popSymboleStack(p);
  printf("pop\n");
    popSymboleStack(p);
  printf("pop\n");
  
  top = topSymboleStack(p);
  printf("top = %d\n", *((int*)top));
  popSymboleStack(p);
  printf("pop\n");
  destroySymboleStack(p);

  return 0;  
}
