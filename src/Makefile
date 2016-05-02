TESTDIR=tests
TESTS=	test_alu test_adc test_sbc test_and test_eor \
		test_cmp test_logic test_absolute_addr \
		test_sta test_zp test_ldx
ASMDIR=asm
SUBMODULES= alu.sv

.PHONY: all
all: Vcpu $(TESTS)

# Verilator
V%: %.sv $(TESTDIR)/%_tb.cpp
	verilator -Wall -Wno-lint --cc $< $(SUBMODULES) --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

# xa65 (6502 assembler)
test_%: $(ASMDIR)/test_%.s
	xa -o $@ $^

.PHONY: run_test_*
run_test_%: test_%
	obj_dir/Vcpu $^

.PHONY: clean
clean:
	rm -rf obj_dir/ test_*
