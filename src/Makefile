TESTDIR=tests

.PHONY: all
all: Vcpu

# Icarus Verilog
%.vpp: %.v $(TESTDIR)/%_tb.v
	iverilog -o $@ $^

# Verilator
V%: %.sv $(TESTDIR)/%_tb.cpp
	verilator -Wall -Wno-lint --cc $< --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

.PHONY: clean
clean:
	rm -rf *.vpp *.vcd obj_dir/
