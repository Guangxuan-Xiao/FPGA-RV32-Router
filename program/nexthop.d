
nexthop.elf:     file format elf32-littleriscv


Disassembly of section .text:

80000000 <write-0x10>:
80000000:	202000b7          	lui	ra,0x20200
80000004:	00a06113          	ori	sp,zero,10
80000008:	123451b7          	lui	gp,0x12345
8000000c:	6001e193          	ori	gp,gp,1536

80000010 <write>:
80000010:	0030a023          	sw	gp,0(ra) # 20200000 <write-0x5fe00010>
80000014:	0030a223          	sw	gp,4(ra)
80000018:	0000a203          	lw	tp,0(ra)
8000001c:	0040a203          	lw	tp,4(ra)
80000020:	00808093          	addi	ra,ra,8
80000024:	fff10113          	addi	sp,sp,-1
80000028:	00118193          	addi	gp,gp,1 # 12345001 <write-0x6dcbb00f>
8000002c:	fe0112e3          	bnez	sp,80000010 <write>
80000030:	202000b7          	lui	ra,0x20200
80000034:	04006113          	ori	sp,zero,64

80000038 <read>:
80000038:	0000a203          	lw	tp,0(ra) # 20200000 <write-0x5fe00010>
8000003c:	0040a203          	lw	tp,4(ra)
80000040:	00808093          	addi	ra,ra,8
80000044:	fff10113          	addi	sp,sp,-1
80000048:	fe0118e3          	bnez	sp,80000038 <read>

8000004c <end>:
8000004c:	0000006f          	j	8000004c <end>
