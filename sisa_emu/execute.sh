#!/bin/bash
./sisa-emu -v -l addr=0x1000,file=fibonacci.code.DE1.hex -c 0xA000 syscode.hex sysdata.hex -d 0x9000 -p 0xA000 -b 0x10ce
