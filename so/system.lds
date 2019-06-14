/*
 *  Canviem l'script per defecte
 *   per adequar-lo a l'arquitectura
 */
OUTPUT_FORMAT("elf32-sisa","elf32-sisa","elf32-sisa")
OUTPUT_ARCH(sisa)
SECTIONS
{
  /* Ens situem a la part de flash */
  . = 0xA000 ;

  /* text space */
  .sistema :
  {
    entrada.o(.text) rsg.o(.text) system.o(.text)
    entrada.o(.rodata) rsg.o(.rodata) system.o(.rodata)
    . = ALIGN(2);
  }
  __entry_point = LOADADDR(.sistema);

  PROVIDE (__user_start = .);
  . = 0x1000 ; /* Part d'usuari */

  .user :
  {
  }
  __user_end = __user_start + SIZEOF(.user);
  
   /* Ens situem en la part de sistema */
  . = 0x9000 ;

  .sysdata : { entrada.o(.data) rsg.o(.data) system.o(.data)}
}
