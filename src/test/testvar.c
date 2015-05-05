

void f();
void g();
void h();

void j(); // pas reconnu comme la declaration de j
void j(){}

void f (){
  j();
}

void g(){
  f();



}

void h(){
  f();
  g();
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}
