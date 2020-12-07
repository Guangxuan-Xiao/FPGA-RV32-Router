
trie.elf:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <trie-0x14>:
80000000:	200000b7          	lui	ra,0x20000
80000004:	00008137          	lui	sp,0x8
80000008:	02106193          	ori	gp,zero,33
8000000c:	12345237          	lui	tp,0x12345
80000010:	67826213          	ori	tp,tp,1656

80000014 <trie>:
80000014:	0040a023          	sw	tp,0(ra) # 20000000 <trie-0x60000014>
80000018:	0000a283          	lw	t0,0(ra)
8000001c:	002080b3          	add	ra,ra,sp
80000020:	fff18193          	addi	gp,gp,-1 # 8000182b <__BSS_END__+0x7ff>
80000024:	fe0198e3          	bnez	gp,80000014 <trie>

80000028 <end>:
80000028:	0000006f          	j	80000028 <end>
