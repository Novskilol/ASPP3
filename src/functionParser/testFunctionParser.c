#include "functionParser.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char **argv)
{
  char *name="\\return ";
  char *data="this function return PI";
  char *functionName="piPlz";
  FunctionParser fp=createFunctionParser();
  addStatement(fp,name,data);
  parseFunction(fp,functionName,0,"type", NULL);
  resetFunctionParser(fp);
  destroyFunctionParser(fp);
  return EXIT_SUCCESS;

}
