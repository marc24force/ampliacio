OUTPUT_FORMAT("elf32-sisa","elf32-sisa","elf32-sisa")
OUTPUT_ARCH(sisa)

STARTUP(entrada.o)

SECTIONS
{
	. = 0xC000;
	.text.start : { *(.text.start ) }
	.text       : { *(.text) }
	.rodata     : { *(.rodata) *(.rodata*) }
	. = 0x8000;
	.data     : { *(.data) *(.data*) }
	.bss     : { *(.bss) *(.bss*) }
}
