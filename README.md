# nes-pacs

This project aims to emulate the hardware of the Nintendo
Entertainment System (NES) on an Altera Cyclone V FPGA.

![NES mb](img/nes.jpg)

[[img source]](https://133fsb.wordpress.com/2009/11/28/restoring-a-nice-famiclone-part-2)

## Background

The NES uses an 8-bit processor, with a 16-bit address space, based on
the MOS Technology 6502.

## Objectives

Write working implementations of the following NES components in
SystemVerilog:

- Ricoh 2A03 processor (including audio processing unit)
- NES Picture Processing Unit (PPU)

Implement a regression test suite to ensure that the CPU and PPU excecute
instructions accurately. This will begin by writing simulations in quartus
and end with loading NES games onto the fpga.

## Requirements

This project uses the following tools:
- [Icarus Verilog](iverilog.icarus.com)
- [Verilator](veripool.org/wiki/verilator)
- [GNU Make](gnu.org/software/make)

## Project Team

This project is conducted as part of Stephen Edwards' [Embedded
Systems](http://www.cs.columbia.edu/~sedwards/classes/2016/4840-spring/index.html)
(CSEE 4840) course at Columbia University.

- [Philip Schiffrin](https://github.com/nethacker11) (pjs2186)
- [Akira Baruah](https://github.com/akira-baruah) (akb2158)
- [Chaiwen Chou](https://github.com/chaiwen) (cc3636)
- [Sean Liu](https://github.com/seansliu) (sl3497)

## References
*Coming soon!*
