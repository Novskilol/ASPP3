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
  parseFunction(fp,functionName);
  resetFunctionParser(fp);
  return EXIT_SUCCESS;

}
