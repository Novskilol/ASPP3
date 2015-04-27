#include <stdio.h>
#include <stdlib.h>
#include "symboleList.h"

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
  SymboleList l= createSymboleList(compareFunction,destroyFunction);
  addSymboleList(l,&a);
  addSymboleList(l,&b);
  addSymboleList(l,&c);
  printf("VALUE %d\n",*(int *)searchSymboleList(l,&b));
  destroySymboleList(l);

}
