.macro $movei p1 imm16
        movi    \p1, lo(\imm16)
        movhi   \p1, hi(\imm16)
.endm


.text
       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
       ; Inicializacion
       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
       $MOVEI r1, RSG
       wrs    s5, r1      ;inicializamos en S5 la direccion de la rutina de antencion a las interrupcciones
       movi   r1, 0xF
       out     9, r1      ;activa todos los visores hexadecimales
       movi   r1, 0xFF
       out    10, r1      ;muestra el valor 0xFFFF en los visores
       $MOVEI r6, inici   ;adreça de la rutina principal
       movi   r1, 0x02    
       wrs    s7, r1      ;Desactivamos el modo sistema 
       jmp    r6

       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
       ; Rutina de servicio excepcion
       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
RSG:   
	reti



       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
       ; Rutina principal
       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
inici: 
       movi r0, 0 ; r0 contador
       movhi r0,0 

       movi r1,0x0	;iniciamos r1 con 1
       halt ; movrs r1, r1, 0 1001 001 001 110 000 = 9270

       movi r1,0x1	;iniciamos r1 con 1
       halt ; movrs r1, r1, 1 1001 001 001 110 001 = 9271

       movi r1,0x2	;iniciamos r1 con 1
       halt ; movrs r1, r1, 2 1001 001 001 110 010 = 9272

       movi r1,0x3	;iniciamos r1 con 1
       halt ; movrs r1, r1, 3 1001 001 001 110 011 = 9273

       movi r1,0x4	;iniciamos r1 con 1
       halt ; movrs r1, r1, 4 1001 001 001 110 100 = 9274

       movi r1,0x5	;iniciamos r1 con 1
       halt ; movrs r1, r1, 5 1001 001 001 110 101 = 9275

       movi r1,0x6	;iniciamos r1 con 1
       halt ; movrs r1, r1, 6 1001 001 001 110 110 = 9276

       movi r1,0x7	;iniciamos r1 con 1
       halt ; movrs r1, r1, 7 1001 001 001 110 111 = 9277

       halt ; sts 0(r0), r1; store en mem[0] =01234567 en addr distintas
       ; 1100 0010 0000 0000  = C200

       halt ; movrs r1, r0, 4 1001 001 000 110 100 = 9234
       halt ; movrs r1, r0, 3 1001 001 000 110 011 = 9233
       halt ; movrs r1, r0, 7 1001 001 000 110 111 = 9237

       halt ; lds 0(r0), r1; load en mem[0]  
       ; 1011 0010 0000 0000  = B200

       halt ; sts 15(r0), r1; store en mem[0] =01234567 en addr distintas
       ; 1100 0010 0000 1111  = C20f

       halt

;mem[0] 0
;...
;mem[7] 7
;mem[f] 0
;...
;mem[f+7] 7

