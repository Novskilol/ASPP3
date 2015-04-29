int constante;

int f();

int f() { 
	return 4;
}

int main() {
	f();
	{ 
		int constante = 16;
	}
	constante = 42;
	{ 
		int constante = 16;
		constante = 2;
	}

	constante = 1;
}
