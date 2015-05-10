#include "util.h"

char * copy(const char * s)
{
	if (s == NULL)
		return NULL;

	size_t size = strlen(s) + 1;

	char * res = malloc(sizeof(*res) * size);
	strcpy(res, s);

	return res;
}
void destroyChar(void *a)
{
  free(a);
}
int compareChar(void *a,void *b)
{
  return strcmp((char*)a,(char*)b) == 0 ;

}

char * replace(const char * s, char bad, const char * replace) {
	int count = 0;
	const char *tmp;

	for(tmp=s; *tmp; tmp++)
		count += (*tmp == bad);

	size_t size_replace = strlen(replace);

	char * res = malloc(strlen(s) + (size_replace - 1) * count + 1);
	char * ptr = res;
	for(tmp = s; *tmp; tmp++) {
		if(*tmp == bad) {
			memcpy(ptr, replace, size_replace);
			ptr += size_replace;
		}
		else {
			*ptr++ = *tmp;
		}
	}
	*ptr = 0;
	return res;
}

void appendFile(FILE * dest, char * src) {
	int fd = open(src, O_RDONLY, 0444);
	char c;
	while(read(fd, &c, 1) > 0)
		fprintf(dest,"%c", c);
	close(fd);
}

char *concat(const char *a,const char *b)
{
  char *r=calloc((strlen(a)+strlen(b)+1),sizeof(char));
  strcat(r,a);
  strcat(r,b);
  return r;

}
