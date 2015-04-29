#include "util.h"

char * copy(char * this)
{
	if (this == NULL) 
		return NULL;
	int size = strlen(this) + 1;
	char * res = malloc(sizeof(*res) * size);
	strcpy(res, this);
	return res;
}
