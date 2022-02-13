BUILD = ./build
UTIL = ./util
SRCS = ./src
TB = ./tests

TESTBENCH_VVP = $(BUILD)/uut.vvp
TESTBENCH_CORE = $(TB)/core_tb.v

JUPITER_HEX = $(BUILD)/jupiter_asm.hex
JUPITER_MCH = $(BUILD)/machine.m
JUPITER_ASM = $(UTIL)/asm/assembly.s

.PHONY: asm test clean

$(TESTBENCH_VVP): $(SRCS) $(TB)
	mkdir -p build/
	iverilog -o $(TESTBENCH_VVP) $(TESTBENCH_CORE) -I $(SRCS)

$(JUPITER_HEX): $(JUPITER_ASM)
	steam-run jupiter $(JUPITER_ASM) --dump-code $(JUPITER_MCH)
	python3 $(UTIL)/asm/format_from_jupiter.py $(JUPITER_MCH) > $(JUPITER_HEX)

test: $(TESTBENCH_VVP)
	vvp $(TESTBENCH_VVP)

asm: $(JUPITER_HEX)

clean:
	rm -r $(BUILD)
