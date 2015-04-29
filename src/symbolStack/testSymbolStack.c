
/* test_stack.c */

#include "symbolStack.h"
#include "stdio.h"

int main (int argc, char* argv[]) 
{
  SymbolStack p=createSymbolStack();
  int a=1, b=2, c=3;
  printf("push %d\n", a);
  pushSymbolStack(p, &a);
  printf("push %d\n", b);
  pushSymbolStack(p, &b);
  printf("push %d\n", c);
  pushSymbolStack(p, &c);

  void * top = topSymbolStack(p);
  printf("top = %d\n", *((int*)top));
  popSymbolStack(p);
  printf("pop\n");
    popSymbolStack(p);
  printf("pop\n");
  
  top = topSymbolStack(p);
  printf("top = %d\n", *((int*)top));
  popSymbolStack(p);
  printf("pop\n");
  destroySymbolStack(p);

  return 0;  
}
