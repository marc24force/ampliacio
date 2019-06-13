#include "system.h"
// inicialitzacio del sistema
//struct task_struct * task0;
//struct task_struct * task1;

//struct task_struct * task_run; // punter a la tasca que sesta executant
//struct task_struct * task_ready; // punter a la tasca que esta esperant

uint16_t * PCB_task0 = (uint16_t *)0x8000;
uint16_t * PCB_task1 = (uint16_t *)0x8500;
uint16_t * run_task;
uint16_t * ready_task;
#define PCB_SIZE 0x500/2
#define task0_code 0x1000
#define task0_stack 0x09FE
#define task1_code 0x3000
#define task1_stack 0x29FE

//definit a rsg.s
extern void RSG();
extern int tics_timer;
extern int tecla_pulsada;

void init_task0() {
	*(PCB_task0) = 0; //PID
	*(PCB_task0+1) = (uint16_t)(PCB_task0 + PCB_SIZE); //kernel ebp
	//*(PCB_task0+2) = (uint16_t)(PCB_task0 + PCB_SIZE); //kernel esp

}
void init_task1() {

	*(PCB_task1) = 1; //PID
	//kernel ebp, el 12+2 surt de la llibreta
	uint16_t * kernel_ebp = (uint16_t *)(PCB_task1 + PCB_SIZE - 14);
	*(PCB_task1+1) = (uint16_t)(kernel_ebp) - 6; //kernel ebp
	//*(PCB_task1+2) = (uint16_t)(kernel_ebp) - 6; //kernel esp
	
	//Return from first task switch
	*(kernel_ebp+1) = ((uint16_t)&RSG + 104); //92 instruccions fins a __finRSG 
	*(kernel_ebp+2) = (uint16_t)(PCB_task1 + PCB_SIZE); //s6 pila sist 
	*(kernel_ebp+3) = task1_code; //s4 pila user
	*(kernel_ebp+4) = 0; //s3
	*(kernel_ebp+5) = task1_code; //s1
	*(kernel_ebp+6) = 2; //s0
	//Regs
	*(kernel_ebp+7) = 6; 
	*(kernel_ebp+8) = 5;
	*(kernel_ebp+9) = 4;
	*(kernel_ebp+10) = 3;
	*(kernel_ebp+11) = 2;
	*(kernel_ebp+12) = 1;
	*(kernel_ebp+13) = 0;
}
void task_switch() {

	uint16_t * tmp_task = ready_task;
	ready_task = run_task;
	run_task = tmp_task;
	__asm__(
		"st 2(%1), r7\n\t"
		"ld r7, 2(%0)\n\t"
		//"addi r7, r7, -6"
		: //sense sortides
		: "r" ((int)run_task), "r" ((int)ready_task)
	);
	//change return address
}

void return_user () {
    int s7_content = 2;//*(kernel_esp - 3); // s(7)
    int s5_content = (int)&RSG;//*(kernel_esp - 5); // s(7)
    __asm__ (
	"movi r0, lo(0x8500)\n\t"
	"movhi r0, hi(0x8500)\n\t"
	"wrs s6, r0\n\t"
	"wrs s7, %0\n\t"
	"wrs s5, %1\n\t"
	"movi r0, 0\n\t"
	"movi r1, 1\n\t"
	"movi r2, 2\n\t"
	"movi r3, 3\n\t"
	"movi r4, 4\n\t"
	"movi r5, 5\n\t"
	"movi r6, 6\n\t"
	"movi r6, lo(0x1000)\n\t"
	"movhi r6, hi(0x1000)\n\t"
	"movi r7, lo(0x1000)\n\t" //aixo amb el entry.s no cal en realitat
	"movhi r7, hi(0x1000)\n\t"
	"jmp r6"
	: // sense sortida
	: "r" (s7_content), "r" (s5_content)  
	);
}

int count=0; //FALTA TOT LO DEL QUANTUM
void C_RSI_Timer () {
	if(count==10) {
		count = 0;
		task_switch();
	}
	//count++;
//	if (count == task_run->quantum)
}
int main () {
    // activar el bit de mode system, harcodejarlo en el boot
    init_task0();
    init_task1();
    run_task = PCB_task0; 
    ready_task = PCB_task1;
    return_user();
    while (1);
    return 0;
}
