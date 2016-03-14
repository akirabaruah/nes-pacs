TESTDIR=tests

.PHONY: all
all: register.vpp Vregister

# Icarus Verilog
%.vpp: %.v $(TESTDIR)/%_tb.v
	iverilog -o $@ $^

# Verilator
V%: %.v $(TESTDIR)/%_tb.cpp
	verilator -Wall --cc $< --exe $(word 2,$^)
	make --quiet -C obj_dir/ -j -f $@.mk $@

.PHONY: clean
clean:
	rm -rf *.vpp *.vcd obj_dir/
