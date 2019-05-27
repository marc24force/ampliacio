#!/bin/bash
./sisa-emu -t -v -l addr=0x1000,file=user_vga.hex -c 0xA000 syscode.hex sysdata.hex -p 0xA000
