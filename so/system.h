
#define uint16_t short
#define KERNEL_STACK_SIZE 64

struct task_struct {
  uint16_t PID;			/* Process ID. This MUST be the first field of the struct. */
  uint16_t * kernel_esp; 
  uint16_t quantum;

};

union task_union {
    struct task_struct task;
    uint16_t stack[KERNEL_STACK_SIZE];    /* pila de sistema, per procés */
};
