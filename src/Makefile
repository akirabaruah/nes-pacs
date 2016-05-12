TESTDIR=tests
TESTS=	test_absolute_addr test_absx test_absy test_adc test_alu test_and \
		test_cmp test_eor test_indx test_indy test_ldx test_logic test_ora \
		test_sbc test_sta test_zp test_zpx test_zpy

ASMDIR=asm
SUBMODULES= alu.sv

.PHONY: all
all: Vcpu $(TESTS) sim

.PHONY: sim
sim:
	make -C std/

# Verilator
V%: %.sv $(TESTDIR)/%_tb.cpp
	verilator +define+$(def) -Wall -Wno-lint --cc $< $(SUBMODULES) --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

# xa65 (6502 assembler)
test_%: $(ASMDIR)/test_%.s
	xa -o $@ $^

.PHONY: test_all
test_all: $(TESTS)
	@echo 'Test Diffs (verilog <> standard)' > test.dump
	@for test in $^; do \
		$(TESTDIR)/test.sh $$test test.dump; \
	done

.PHONY: run_test_*
run_test_%: test_%
	obj_dir/Vcpu $^

.PHONY: clean
clean:
	rm -rf obj_dir/ test_*
	make -C std/ clean
