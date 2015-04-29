#include "commun.h"


void indentThat() {
    int i=0;
    for(; i < indent; i++) {
        printf(SPACE_C);
    }
}

char * copy(char * this)
{
  if (this == NULL) 
    return NULL;
  int size = strlen(this) + 1;
  char * res = malloc(sizeof(*res) * size);
  strcpy(res, this);
  return res;
}
