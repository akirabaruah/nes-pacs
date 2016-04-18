TESTDIR=tests
ASMDIR=asm
SUBMODULES= alu.sv

.PHONY: all
all: Vcpu test.out test_alu.out

.PHONY: run_test
run_test: test.out
	obj_dir/Vcpu $^

.PHONY: run_alu_test
run_alu_test: test_alu.out
	obj_dir/Vcpu $^

# Verilator
V%: %.sv $(TESTDIR)/%_tb.cpp
	verilator -Wall -Wno-lint --cc $< $(SUBMODULES) --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

# xa65 (6502 assembler)
%.out: $(ASMDIR)/%.s
	xa -o $@ $^

.PHONY: clean
clean:
	rm -rf obj_dir/ *.out
