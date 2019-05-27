TARGET = $(notdir $(CURDIR))

CFILES 	:= $(notdir $(wildcard *.c))
SFILES	:= $(notdir $(wildcard *.s))
OBJS	:= $(CFILES:.c=.o) $(SFILES:.s=.o)

CFLAGS =  -g3 -O0 -Wall -DVERSION=\""1.7"\"

all: $(TARGET) $(TARGET).code.hex $(TARGET).data.hex

$(TARGET): $(OBJS)
	@sisa-ld -T linker.lds $^ -o $@

.c.o:
	@sisa-gcc $(CFLAGS) -c $< -o $@

.s.o:
	@sisa-as $< -o $@

disasm: $(TARGET)
	@sisa-objdump -d -S -x -w $<

rom: $(TARGET).code.bin $(TARGET).data.bin
	@echo "Code:"
	@hexdump -ve '1/2 "%.4x\n"' $(TARGET).code.bin
	@echo "\nData:"
	@hexdump -ve '1/2 "%.4x\n"' $(TARGET).data.bin

hex: $(TARGET).code.bin $(TARGET).data.bin
	@hexdump -ve '1/2 "%.4x\n"' $(TARGET).code.bin > $(TARGET).code.hex
	@hexdump -ve '1/2 "%.4x\n"' $(TARGET).data.bin > $(TARGET).data.hex

$(TARGET).code.bin: $(TARGET)
	@sisa-objcopy -O binary -j .text $< $@

$(TARGET).data.bin: $(TARGET)
	@sisa-objcopy -O binary -j .data $< $@

%.hex: %.bin
	@hexdump -ve '1/2 "%.4x\n"' $< > $@

clean:
	@rm -f $(TARGET) $(TARGET).code.bin $(TARGET).data.bin \
	$(TARGET).code.hex $(TARGET).data.hex $(OBJS)
