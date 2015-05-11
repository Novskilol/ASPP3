#include "util.h"


int fileSize(const char *fileName)
{
  FILE *f=fopen(fileName,"r");
  int nb;
  char buffer;
  int sizeFile;

  for(sizeFile = 0 ;(nb = fread(&buffer,sizeof(char),1,f)) > 0 ; sizeFile+=nb );

  fclose(f);
  return sizeFile;


}
char *fileToChar(const char *fileName,int sizeFile)
{
  FILE *f=fopen(fileName,"r");
  char *ret = malloc( sizeof(char) * (sizeFile+1) );
  int i;
  int nb;
  char buffer;
  int sizeRead;
  for (sizeRead = 0;(nb = fread(&buffer,sizeof(char),1,f)) > 0 ; sizeRead +=nb)
    for (i = 0 ; i < nb ; i++ )
      ret[i+sizeRead]=buffer;
  fclose(f);
  ret[sizeFile] =0;
  return ret;
}
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

void appendSidebar(FILE * dest, char **filesArray, int size, char *fileName, bool isCode)
{
	fprintf(dest, "<div id=\"sidebar\"><div id='cssmenu'><ul>");
	fprintf(dest, "<li><a href='#'><span>Top</span></a></li>");

	if (isCode == true)
		fprintf(dest, "<li><a href='../%s.doc.html'><span>See Doc.</span></a></li>", fileName);
	else
		fprintf(dest, "<li><a href='../%s.html'><span>See Code</span></a></li>", fileName);

	fprintf(dest, "<li class='has-sub'><a><span>Code</span></a><ul>");

	int i;
	for (i = 0; i < size; ++i)
	{
		fprintf(dest, "<li><a href='../%s.html'><span>%s</span></a></li>", filesArray[i], filesArray[i]);
	}
	fprintf(dest, "</ul></li><li><a href='latex.html' target='_blank'><span>Rapport</span></a></li></ul></div></div>");
}

char *concat(const char *a,const char *b)
{
  char *r=calloc((strlen(a)+strlen(b)+1),sizeof(char));
  strcat(r,a);
  strcat(r,b);
  return r;

}
