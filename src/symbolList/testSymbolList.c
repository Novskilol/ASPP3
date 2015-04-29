#include <stdio.h>
#include <stdlib.h>
#include "symbolList.h"

void destroyFunction(void *a)
{

}
int compareFunction(void *a,void *b)
{

  return (*(int*)a) == (*(int*)b);
}
int main(int argc,char **argv)
{

  int a=40;
  int b=50;
  int c=60;
  SymbolList l= createSymbolList(compareFunction,destroyFunction);
  addSymbolList(l,&a);
  addSymbolList(l,&b);
  addSymbolList(l,&c);
  printf("VALUE %d\n",*(int *)searchSymbolList(l,&b));
  destroySymbolList(l);

  return 0;
}
