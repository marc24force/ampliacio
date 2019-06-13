#!/bin/bash

./sisa-emu -v -l addr=0x1000,file=fibonacci.code.DE1.hex -l addr=0x3000,file=corre_letras.code.DE1.hex -l addr=0x2000,file=corre_letras.code.DE1.hex -c 0x4000 syscode.hex sysdata.hex -d 0x9000 -p 0x4000 -b 0x34d6
