#include "lib_sisa.h"
int lib_getticks(){
	int getticks = 0; //syscall 0
	int res = 0;
	__asm__ (
		"calls %1\n\t"
		"addi %0, r1, 0\n\t" //aixo esta aqui perque si no no se com treureho asm->c
		: "=r" (res)
		: "r" (getticks)
	        );
	return res;	

}

int lib_getkeyboard(){

	int getkeyboard = 1; //syscall 0
	int res = 0;
	__asm__ (
		"calls %1\n\t"
		"addi %0, r1, 0\n\t"
		: "=r" (res)
		: "r" (getkeyboard)
	        );
	return res;	
}
