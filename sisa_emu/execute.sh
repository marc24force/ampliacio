#!/bin/bash
./sisa-emu -v -l addr=0x1000,file=usr_led.hex -c 0xA000 syscode.hex sysdata.hex -p 0xA000 -b 0x1000
