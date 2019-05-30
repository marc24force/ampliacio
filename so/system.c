#include "system.h"
// inicialitzacio del sistema
struct task_struct * task0;
struct task_struct * task1;

struct task_struct * task_run; // punter a la tasca que sesta executant

void init_sys_regs (struct task_struct * task) {
    *(task->kernel_esp - 2) = 2; // s(7)
    *(task->kernel_esp - 6) = 0; // s(3)
    *(task->kernel_esp - 7) = 0; // s(2)
    *(task->kernel_esp - 8) = *(task->kernel_esp - 1); // s(1)
    *(task->kernel_esp - 9) = 0; // s(0)

}

void init_task0 () {
    task0->PID = 0;
    task0->kernel_esp = (uint16_t*)task0 + KERNEL_STACK_SIZE - 1;
    task0->quantum = 1; //a cada interrupcio del timer
    *(task0->kernel_esp) = (uint16_t)(0x1000 - 1); //direccio del stack que hem considerat
    *(task0->kernel_esp - 1) = (uint16_t)0x1000; // direccio del codi
    init_sys_regs (task0);
    
}

void init_task1 () {
    task1->PID = 1;
    task1->kernel_esp = (uint16_t*)task1 + KERNEL_STACK_SIZE - 1;
    task1->quantum = 1; //a cada interrupcio del timer
    *(task1->kernel_esp) = (uint16_t)(0x3000 - 1); //direccio del stack que hem considerat
    *(task1->kernel_esp - 1) = (uint16_t)0x3000; // direccio del codi
    init_sys_regs (task1);

}

void return_user () {
    // jal al codi de task0
    int reg;
    int s7 = *(task0->kernel_esp - 2); // s(7)
    int reg7 = 7;
    __asm__ (

	"wrs s7, %2\n\t"
	"movi %0, lo(0x1000)\n\t"
	"movhi %0, hi(0x1000)\n\t"
	"jmp %0"
	: // sense sortida
	: "r" (reg), "r" (7), "r" (s7)  
	);
}

int count;
void RSI_Timer () {
	count++;
//	if (count == task_run->quantum)
}
int main () {
    // activar el bit de mode system, harcodejarlo en el boot
    init_task0();
    init_task1();
    task_run = task0;
    return_user();
    while (1);
    return 0;
}