#!/bin/bash


echo "Ensamblando ..."
#compila el ensamblador
sisa-as system.s -o system.o

echo "Compilando ..."
#compila el c (solo compila)  (para ver el codigo fuente entre el codigo desensamblado hay que compilar con la opcion -O0)
#sisa-gcc -g3 -c  lib_sisa.c -o lib_sisa.o
sisa-gcc -gstabs -c -Wall -Wextra -O2 system.c -o system.o 

echo "Linkando ..."
#Linkamos los ficheros (la opcion -s es para que genere menos comentarios)
sisa-ld -s -T system.lds system.o -o tmp_system.o

#desensamblamos el codigo
sisa-objdump -d -z --section=.sistema tmp_system.o >system.code
sisa-objdump -s -z --section=.sysdata tmp_system.o >system.data

./limpiar.pl codigo system.code
./limpiar.pl datos system.data

#Linkamos los ficheros (sin la opcion -s es para que genere mas comentarios) y desensamblamos
#(para ver el codigo fuente entre el codigo desensamblado hay que haber compilado con la opcion -O0)
sisa-ld -T system.lds -o tmp_system.o

sisa-objdump -S -x -w --section=.sistema tmp_system.o >system.dis
sisa-objdump -S -x -w --section=.sysdata tmp_system.o >>system.dis

rm system.o tmp_system.o system.code system.data

