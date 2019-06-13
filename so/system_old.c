#include "system.h"
// inicialitzacio del sistema
struct task_struct * task0;
struct task_struct * task1;

struct task_struct * task_run; // punter a la tasca que sesta executant
struct task_struct * task_ready; // punter a la tasca que esta esperant


extern void RSG();

void init_sys_regs (struct task_struct * task) {
    *(task->kernel_esp - 2) = 2; // s(7)
    *(task->kernel_esp - 4) = (uint16_t)(int)&RSG; // s(5)
    *(task->kernel_esp - 6) = 0; // s(3)
    *(task->kernel_esp - 7) = 0; // s(2)
    *(task->kernel_esp - 8) = *(task->kernel_esp - 1); // s(1)
    *(task->kernel_esp - 9) = 0; // s(0)

}

void init_task0 () {
    task0->PID = 0;
    task0->kernel_esp = (uint16_t*)task0 + KERNEL_STACK_SIZE - 1;
    task0->quantum = 1; //a cada interrupcio del timer
    
    uint16_t dir_codi,dir_esp;
    __asm__ (
	"movi %0, lo(0x0FFE)\n\t"
	"movhi %0, hi(0x0FFE)\n\t"
	: //sense sortida
	: "r" (dir_esp)
    );
    *(task0->kernel_esp) = dir_esp; //direccio del stack que hem considerat
    __asm__ (
	"movi %0, lo(0x1000)\n\t"
	"movhi %0, hi(0x1000)\n\t"
	: //sense sortida
	: "r" (dir_codi)
    );
    *(task0->kernel_esp - 1) = dir_codi; // direccio del codi

    init_sys_regs (task0);
    
}

void init_task1 () {
    task1->PID = 1;
    task1->kernel_esp = (uint16_t*)task1 + KERNEL_STACK_SIZE - 1;
    task1->quantum = 1; //a cada interrupcio del timer

    uint16_t dir_codi,dir_esp;
    __asm__ (
	"movi %0, lo(0x2FFE)\n\t"
	"movhi %0, hi(0x2FFE)\n\t"
	: //sense sortida
	: "r" (dir_esp)
    );
    *(task1->kernel_esp) = dir_esp; //direccio del stack que hem considerat
    __asm__ (
	"movi %0, lo(0x3000)\n\t"
	"movhi %0, hi(0x3000)\n\t"
	: //sense sortida
	: "r" (dir_codi)
    );
    *(task1->kernel_esp - 1) = dir_codi; // direccio del codi


    init_sys_regs (task1);

}

void task_switch() {
	//aconseguir l'estat del que esta en run
	int pc_run_val=0;
	__asm__ (
	    "rds %0, s1\n\t"
	    : "=r"(pc_run_val)
	    : //sense entrada
	);
	//guardar l'estat del que esta en run
	//*((int *)task_run + KERNEL_STACK_SIZE - 1) = esp_run_val;
	*((int *)task_run + KERNEL_STACK_SIZE - 2) = pc_run_val;
	
///////////////////////////
	//aconseguir l'estat del que esta en ready
	//int esp_new_value = *((int *)task_ready + KERNEL_STACK_SIZE - 1);
	int pc_new_value = *((int *)task_ready + KERNEL_STACK_SIZE - 2);
	//carregar l'estat del que esta en ready
	__asm__ (
	   "jmp %0"
	   : //sense sortida 
	   : "r" (pc_new_value)
        ); 
}

void return_user () {
    // jal al codi de task0
    int reg_jump;
    int s7_content = *(task0->kernel_esp - 2); // s(7)
    int s5_content = 0xA000 | *(task0->kernel_esp - 4); // s(7)
    __asm__ (
	"wrs s7, %1\n\t"
	"wrs s5, %2\n\t"
	"movi %0, lo(0x1000)\n\t"
	"movhi %0, hi(0x1000)\n\t"
	"jmp %0"
	: // sense sortida
	: "r" (reg_jump), "r" (s7_content), "r" (s5_content)  
	);
}

int count;
void RSI_Timer () {
	task_switch();
	//count++;
//	if (count == task_run->quantum)
}
int main () {
    // activar el bit de mode system, harcodejarlo en el boot
    init_task0();
    init_task1();
    task_run = task0;
    task_ready = task1;
    return_user();
    while (1);
    return 0;
}
