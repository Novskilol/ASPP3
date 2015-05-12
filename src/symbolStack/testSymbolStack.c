#include <stdio.h>
#include <stdlib.h>

#include "symbolStack.h"

static void testPush(SymbolStack stack, int obj)
{
  int * o = malloc(sizeof(*o));
  *o = obj;
  printf("push %d\n", *o);
  pushSymbolStack(stack, o);
}

static void testPop(SymbolStack stack)
{
  int * top = topSymbolStack(stack);
  printf("top = %d\n", *top);
  free(top);
  popSymbolStack(stack);
}

int main (int argc, char* argv[])
{
  SymbolStack s=createSymbolStack();
  int a=1, b=2, c=3;

  testPush(s, a);
  testPush(s, b);
  testPush(s, c);

  testPop(s);
  testPop(s);
  testPop(s);

  destroySymbolStack(s);

  return 0;
}
