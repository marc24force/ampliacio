.include "macros.s" 
.set PILA, 0x9500     
.set INICI, 0xA000
; una posición de memoria de una zona no ocupada para usarse como PILA 
; seccion de datos 
.data 
	.balign 2                    
	; por si acaso, pero no debería ser necesario
	interrupts_vector: 
		.word RSI_Timer ; 0
		.word RSI_default_resume ; 1 Pulsadores (KEY) 
		.word RSI_default_resume ; 2 Interruptores (SWITCH)
		.word RSI_default_resume ; 3 Teclado PS/2 
	exceptions_vector: 
		.word RSE_default_halt   ;  0 Instrucción ilegal 
		.word RSE_default_halt   ;  1 Acceso a memoria no alineado 
		.word RSE_default_resume 
		;  2 Overflow en coma flotante 
		.word RSE_default_resume 
		;  3 División por cero en coma flotante 
		.word RSE_default_halt   
		;  4 División por cero 
		.word RSE_default_halt   
		;  5 No definida 
		.word RSE_excepcion_TLB  
		;  6 Miss en TLB de instrucciones 
		.word RSE_excepcion_TLB  
		;  7 Miss en TLB de datos 
		.word RSE_excepcion_TLB  
		;  8 Página inválida al TLB de instrucciones 
		.word RSE_excepcion_TLB  
		;  9 Página inválida al TLB de datos 
		.word RSE_default_halt   
		; 10 Página protegida al TLB de instrucciones 
		.word RSE_default_halt   
		; 11 Página protegida al TLB de datos 
		.word RSE_default_halt   
		; 12 Página de sólo lectura 
		.word RSE_default_halt   
		; 13 Excepción de protección 
	call_sys_vector: 
		.word RSE_default_resume 
		; 0 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 1 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 2 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 3 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 4 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 5 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 6 Hay que definirla en el S.O. 
		.word RSE_default_resume 
		; 7 Hay que definirla en el S.O. 
; sección de código 
.text 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
	; Inicialización 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
		    $MOVEI r1, RSG 
		    wrs    s5, r1      
		; inicializamos en S5 la dirección de la rutina de atención a la interrupción 
		    $MOVEI r7, PILA    
		; inicializamos R7 como puntero a la pila 
		    $MOVEI r6, INICI   
		; dirección de la rutina principal 
		    jmp    r6 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
	; Rutinas de servicio por defecto 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
		    RSE_default_halt:   HALT 
		    RSI_default_halt:   HALT 
		    RSE_default_resume: JMP R6 
		    RSI_default_resume: JMP R6 
		    RSE_excepcion_TLB:   
		; fragmento de código
		; falta el código de la tarea a hacer 
		   rds   R2, S1     
		; hay que volver a ejecutar la instrucción que ha fallado
		addi  R2, R2, -2 
		wrs   S1, R2 
		JMP R6 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
	; Rutina de servicio de interrupción 
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=* 
	RSG: 
		; Salvar el estado
		 $push  R0, R1, R2, R3, R4, R5, R6 
		 rds    R1, S0 
		 rds    R2, S1 
		 rds    R3, S3 
		 $push  R1, R2, R3 
		 rds    R1, S2                    
		;consultamos el contenido de S2 
		 movi   R2, 14 
		 cmpeq  R3, R1, R2                
		;si es igual a 14 es una llamada a sistema 
		 bnz    R3, __call_sistema        
		;saltamos a las llamadas a sistema si S2 es igual a 14 
		 movi   R2, 15 
		 cmpeq  R3, R1, R2                
		;si es igual a 15 es una interrupción 
		 bnz    R3, __interrupcion        
		;saltamos a las interrupciones si S2 es igual a 15 
	__excepcion: 
		 movi   R2, lo(exceptions_vector) 
		 movhi  R2, hi(exceptions_vector) 
		 add    R1, R1, R1                
		;R1 contiene el identificador de excepción 
		 add    R2, R2, R1 
		 ld     R2, 0(R2) 
		 jal    R6, R2 
		 bz     R3, __finRSG 
	__call_sistema: 
		 rds    R1, S3                    
		;S3 contiene el identificador de la llamada a sistema 
		 movi   R2,7 
		 and    R1, R1, R2  
		;nos quedamos con los 3 bits de menor peso limitar el número de servicios definidos en el S.O. 
		 add    R1, R1, R1 
		 movi   R2, lo(call_sys_vector) 
		 movhi  R2, hi(call_sys_vector) 
		 add    R2, R2, R1 
		 ld     R2, 0(R2) 
		 jal    R6, R2 
		 bnz    R3, __finRSG 
	__interrupcion: 
		 getiid R1 
		 add    R1, R1, R1 
		 movi   R2, lo(interrupts_vector) 
		 movhi  R2, hi(interrupts_vector) 
		 add    R2, R2, R1 
		 ld     R2, 0(R2) 
		 jal    R6, R2 
	__finRSG: 
	;Restaurar el estado
		 $pop  R3, R2, R1 
		 wrs   S3, R3 
		 wrs   S1, R2 
		 wrs   S0, R1 
		 $pop  R6, R5, R4, R3, R2, R1, R0 
		 reti

		
