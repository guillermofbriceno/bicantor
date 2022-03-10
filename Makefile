BUILD = ./build
UTIL = ./util

SRCS = ./src/core
#SRCS := ./src/cache

TB = ./tests

TESTBENCH_VVP = $(BUILD)/uut.vvp
TESTBENCH_CORE = $(TB)/core_tb.v

JUPITER_HEX = $(BUILD)/jupiter_asm.hex
JUPITER_MCH = $(BUILD)/machine.m
JUPITER_ASM = $(UTIL)/asm/assembly.s

DEFYAML = ./src/defs.yaml
DEFVERI = ./src/defs.v

.PHONY: clean

$(TESTBENCH_VVP): $(SRCS) $(TB) $(DEFVERI) $(JUPITER_HEX)
	mkdir -p build/
	iverilog -o $@ $(TESTBENCH_CORE) -y $(SRCS) -I $(DEFVERI)
	vvp $@

$(JUPITER_HEX): $(JUPITER_ASM)
	steam-run jupiter $^ --dump-code $(JUPITER_MCH)
	python3 $(UTIL)/asm/format_from_jupiter.py $(JUPITER_MCH) > $@

$(DEFVERI): $(DEFYAML)
	python3 $(UTIL)/defgen/defgen.py $^ $@

defs: $(DEFVERI)

test: $(TESTBENCH_VVP) 

asm: $(JUPITER_HEX)

clean:
	rm -r $(BUILD)
