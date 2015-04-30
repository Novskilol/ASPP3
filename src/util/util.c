#include "util.h"

/* 
allocate memory, copy argument 
and return the new allocated string 
*/
char * copy(const char * s)
{
	if (s == NULL) 
		return NULL;

	size_t size = strlen(s) + 1;
	
	char * res = malloc(sizeof(*res) * size);
	strcpy(res, s);
	
	return res;
}

/* 
allocate memory, replace every occurences of 'bad' by 'replace'
and return the new allocated string  
*/
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

void appendFile(char * src) {
	int fd = open(src, O_RDONLY, 0444);
	char c;
	while(read(fd, &c, 1) > 0)
		printf("%c", c);
	close(fd);
}
