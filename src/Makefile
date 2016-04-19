TESTDIR=tests
TESTS=	test_alu.out test_adc.out test_sbc.out \
		test_cmp.out test_logic.out
ASMDIR=asm
SUBMODULES= alu.sv

.PHONY: all
all: Vcpu $(TESTS)

# Verilator
V%: %.sv $(TESTDIR)/%_tb.cpp
	verilator -Wall -Wno-lint --cc $< $(SUBMODULES) --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

# xa65 (6502 assembler)
test_%.out: $(ASMDIR)/test_%.s
	xa -o $@ $^

.PHONY: run_test_*
run_test_%: test.out
	obj_dir/Vcpu $^

.PHONY: clean
clean:
	rm -rf obj_dir/ *.out
