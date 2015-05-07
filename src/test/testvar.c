//int i;



void f(int i);
void g(int i);
void h(int i);
void j(int i);



struct olilol{
  int a;
};
olilol j(int i){
i = 4;
}

void f (int i){
  j(i);

  i = 4;
}

void g(int i){
  f(i);

  i = 4;

}

void h(int i){
  f(i);
  i = 42;
  g(i);
  {
  	int i = 2;
  }
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}
