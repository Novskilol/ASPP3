int constante;

int f();

int f() { 
	return 4;
}

int main() {
	f();

if (true) return;
else return;

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
