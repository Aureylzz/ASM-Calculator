TARGET = calculator
ASM_SOURCES = main.asm password.asm io.asm utils.asm operations.asm errors.asm globals.asm menu.asm operand_input.asm
OBJECTS = $(ASM_SOURCES:.asm=.o)
ASMFLAGS = -f elf64 -g dwarf2

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@gcc -no-pie -o $@ $^
	@echo "Linking complete: $(TARGET) generated."

%.o: %.asm
	@yasm $(ASMFLAGS) -l $*.lst $< -o $@
	@echo "Assembly complete: $@ generated. (Listing: $*.lst)"

clean:
	rm -f $(OBJECTS) $(TARGET) *.lst
	@echo "Cleanup complete."

run: all
	@./$(TARGET)

debug: all
	@gdb -q ./$(TARGET)
