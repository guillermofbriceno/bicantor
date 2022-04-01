BUILD = ./build
UTIL = ./util

SRCS = ./src/core
#SRCS := ./src/cache

TB = ./tests

QUICKTESTS_ASM = $(wildcard ./tests/quicktests/*.s)
QUICKTESTS_HEX = $(patsubst ./tests/quicktests/%.s, $(BUILD)/%.hex, $(QUICKTESTS_ASM))


TESTBENCH_VVP = $(BUILD)/uut.vvp
TESTBENCH_CORE = $(TB)/core_tb.v

JUPITER_HEX = $(BUILD)/jupiter_asm
JUPITER_MCH = $(BUILD)/machine.m
JUPITER_ASM = $(UTIL)/asm/assembly.s

DEFYAML = ./src/defs.yaml
DEFVERI = ./src/defs.v

.PHONY: clean

$(TESTBENCH_VVP): $(SRCS) $(TB) $(DEFVERI) $(JUPITER_HEX).hex
	mkdir -p build/
	iverilog -o $@ $(TESTBENCH_CORE) -y $(SRCS) -I $(DEFVERI)
	vvp $@ +TEST=$(JUPITER_HEX)

$(JUPITER_HEX): $(JUPITER_ASM)
	steam-run jupiter $^ --dump-code $(JUPITER_MCH)
	python3 $(UTIL)/asm/format_from_jupiter.py $(JUPITER_MCH) > $@.hex

$(DEFVERI): $(DEFYAML)
	python3 $(UTIL)/defgen/defgen.py $^ $@

$(BUILD)/%.hex: ./tests/quicktests/%.s
	steam-run jupiter $< --dump-code $(BUILD)/temp.m
	python3 $(UTIL)/asm/format_from_jupiter.py $(BUILD)/temp.m > $@

defs: $(DEFVERI)

quicktests:
	python3 $(UTIL)/quicktester/quicktester.py

test: $(QUICKTESTS_HEX) quicktests $(TESTBENCH_VVP)

asm: $(JUPITER_HEX)

clean:
	rm -r $(BUILD)
