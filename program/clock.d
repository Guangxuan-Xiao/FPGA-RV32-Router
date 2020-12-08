
clock.elf:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <loop-0x8>:
80000000:	100000b7          	lui	ra,0x10000
80000004:	0100e093          	ori	ra,ra,16

80000008 <loop>:
80000008:	0000a103          	lw	sp,0(ra) # 10000000 <loop-0x70000008>
8000000c:	ffdff06f          	j	80000008 <loop>
