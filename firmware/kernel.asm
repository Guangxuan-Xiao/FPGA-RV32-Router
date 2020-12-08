
kernel.elf:     file format elf32-littleriscv
kernel.elf
architecture: riscv:rv32, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x80000000

Program Header:
    LOAD off    0x00001000 vaddr 0x80000000 paddr 0x80000000 align 2**12
         filesz 0x000017f8 memsz 0x00001884 flags rwx

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000015f0  80000000  80000000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       00000208  800015f0  800015f0  000025f0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .bss          00000084  80001800  80001800  000027f8  2**2
                  ALLOC
  3 .comment      00000028  00000000  00000000  000027f8  2**0
                  CONTENTS, READONLY
  4 .riscv.attributes 0000001c  00000000  00000000  00002820  2**0
                  CONTENTS, READONLY
  5 .debug_line   0000016c  00000000  00000000  0000283c  2**0
                  CONTENTS, READONLY, DEBUGGING
  6 .debug_info   00000026  00000000  00000000  000029a8  2**0
                  CONTENTS, READONLY, DEBUGGING
  7 .debug_abbrev 00000014  00000000  00000000  000029ce  2**0
                  CONTENTS, READONLY, DEBUGGING
  8 .debug_aranges 00000020  00000000  00000000  000029e8  2**3
                  CONTENTS, READONLY, DEBUGGING
  9 .debug_str    0000010f  00000000  00000000  00002a08  2**0
                  CONTENTS, READONLY, DEBUGGING
SYMBOL TABLE:
80000000 l    d  .text	00000000 .text
800015f0 l    d  .rodata	00000000 .rodata
80001800 l    d  .bss	00000000 .bss
00000000 l    d  .comment	00000000 .comment
00000000 l    d  .riscv.attributes	00000000 .riscv.attributes
00000000 l    d  .debug_line	00000000 .debug_line
00000000 l    d  .debug_info	00000000 .debug_info
00000000 l    d  .debug_abbrev	00000000 .debug_abbrev
00000000 l    d  .debug_aranges	00000000 .debug_aranges
00000000 l    d  .debug_str	00000000 .debug_str
00000000 l    df *ABS*	00000000 printf.c
8000000c l     F .text	00000010 _out_buffer
8000001c l     F .text	00000004 _out_null
80000020 l     F .text	00000534 _ntoa_long
80000554 l     F .text	000007b4 _vsnprintf
80000d08 l     F .text	0000000c _out_char
80000d14 l     F .text	00000014 _out_fct
00000000 l    df *ABS*	00000000 uart.c
00000000 l    df *ABS*	00000000 route_table.c
80001880 l     O .bss	00000004 nexthop_size
80001800 l     O .bss	00000080 layer_size
00000000 l    df *ABS*	00000000 dependencies.c
00000000 l    df *ABS*	00000000 main.c
80000ebc g     F .text	00000018 _putchar
80000f24 g     F .text	0000000c parse_rc
80000ef8 g     F .text	00000010 get_nexthop_ip_addr
80000f80 g     F .text	00000018 set_nexthop
80000ed4 g     F .text	00000024 get_node_addr
80001374 g     F .text	000000c8 search
80001800 g       .bss	00000000 _bss_begin
80000e18 g     F .text	00000030 vprintf_
80000f54 g     F .text	0000002c set_rc
8000121c g     F .text	00000158 remove
80001544 g     F .text	00000048 .hidden __udivsi3
80000d7c g     F .text	00000050 sprintf_
80000000 g       *ABS*	00000000 RAM_BASE
80000eb8 g     F .text	00000004 init_uart
80000e48 g     F .text	0000001c vsnprintf_
80001890 g       .bss	00000000 _bss_end
80000e64 g     F .text	00000054 fctprintf
8000158c g     F .text	00000010 .hidden __umodsi3
80000f1c g     F .text	00000008 parse_lc
8000143c g     F .text	00000038 memset
80000f98 g     F .text	00000084 parse_node
8000153c g     F .text	00000084 .hidden __divsi3
80000dcc g     F .text	0000004c snprintf_
80000d28 g     F .text	00000054 printf_
80000f30 g     F .text	00000008 parse_nexthop
800015c0 g     F .text	00000030 .hidden __modsi3
80001474 g     F .text	000000c8 start
80000f38 g     F .text	0000001c set_lc
8000101c g     F .text	00000200 insert
80000000 g       .text	00000000 _reset_vector
80000f08 g     F .text	00000014 get_nexthop_port_addr



Disassembly of section .text:

80000000 <_reset_vector>:
80000000:	80800137          	lui	sp,0x80800
80000004:	ff010113          	addi	sp,sp,-16 # 807ffff0 <_bss_end+0x7fe760>
80000008:	46c0106f          	j	80001474 <start>

8000000c <_out_buffer>:
8000000c:	00d67663          	bgeu	a2,a3,80000018 <_out_buffer+0xc>
80000010:	00c585b3          	add	a1,a1,a2
80000014:	00a58023          	sb	a0,0(a1)
80000018:	00008067          	ret

8000001c <_out_null>:
8000001c:	00008067          	ret

80000020 <_ntoa_long>:
80000020:	f9010113          	addi	sp,sp,-112
80000024:	00f12423          	sw	a5,8(sp)
80000028:	07412783          	lw	a5,116(sp)
8000002c:	06812423          	sw	s0,104(sp)
80000030:	07212023          	sw	s2,96(sp)
80000034:	4007f793          	andi	a5,a5,1024
80000038:	05312e23          	sw	s3,92(sp)
8000003c:	05412c23          	sw	s4,88(sp)
80000040:	05712623          	sw	s7,76(sp)
80000044:	05912223          	sw	s9,68(sp)
80000048:	03b12e23          	sw	s11,60(sp)
8000004c:	06112623          	sw	ra,108(sp)
80000050:	06912223          	sw	s1,100(sp)
80000054:	05512a23          	sw	s5,84(sp)
80000058:	05612823          	sw	s6,80(sp)
8000005c:	05812423          	sw	s8,72(sp)
80000060:	05a12023          	sw	s10,64(sp)
80000064:	00c12023          	sw	a2,0(sp)
80000068:	00f12623          	sw	a5,12(sp)
8000006c:	00070c93          	mv	s9,a4
80000070:	00050913          	mv	s2,a0
80000074:	00058993          	mv	s3,a1
80000078:	00068a13          	mv	s4,a3
8000007c:	00080413          	mv	s0,a6
80000080:	00088d93          	mv	s11,a7
80000084:	07012b83          	lw	s7,112(sp)
80000088:	0c071463          	bnez	a4,80000150 <_ntoa_long+0x130>
8000008c:	07412703          	lw	a4,116(sp)
80000090:	fef77693          	andi	a3,a4,-17
80000094:	0e079063          	bnez	a5,80000174 <_ntoa_long+0x154>
80000098:	06d12a23          	sw	a3,116(sp)
8000009c:	07412783          	lw	a5,116(sp)
800000a0:	00012223          	sw	zero,4(sp)
800000a4:	06100b13          	li	s6,97
800000a8:	0207f793          	andi	a5,a5,32
800000ac:	0c079063          	bnez	a5,8000016c <_ntoa_long+0x14c>
800000b0:	00000a93          	li	s5,0
800000b4:	01010493          	addi	s1,sp,16
800000b8:	00900c13          	li	s8,9
800000bc:	ff6b0b13          	addi	s6,s6,-10
800000c0:	02000d13          	li	s10,32
800000c4:	00c0006f          	j	800000d0 <_ntoa_long+0xb0>
800000c8:	05aa8463          	beq	s5,s10,80000110 <_ntoa_long+0xf0>
800000cc:	00050c93          	mv	s9,a0
800000d0:	00040593          	mv	a1,s0
800000d4:	000c8513          	mv	a0,s9
800000d8:	4b4010ef          	jal	ra,8000158c <__umodsi3>
800000dc:	0ff57693          	andi	a3,a0,255
800000e0:	03068613          	addi	a2,a3,48
800000e4:	016686b3          	add	a3,a3,s6
800000e8:	0ff6f693          	andi	a3,a3,255
800000ec:	00ac6463          	bltu	s8,a0,800000f4 <_ntoa_long+0xd4>
800000f0:	0ff67693          	andi	a3,a2,255
800000f4:	001a8a93          	addi	s5,s5,1
800000f8:	01548633          	add	a2,s1,s5
800000fc:	000c8513          	mv	a0,s9
80000100:	00040593          	mv	a1,s0
80000104:	fed60fa3          	sb	a3,-1(a2)
80000108:	43c010ef          	jal	ra,80001544 <__udivsi3>
8000010c:	fa8cfee3          	bgeu	s9,s0,800000c8 <_ntoa_long+0xa8>
80000110:	07412783          	lw	a5,116(sp)
80000114:	0027fb13          	andi	s6,a5,2
80000118:	060b0863          	beqz	s6,80000188 <_ntoa_long+0x168>
8000011c:	00412783          	lw	a5,4(sp)
80000120:	0e078863          	beqz	a5,80000210 <_ntoa_long+0x1f0>
80000124:	00c12783          	lw	a5,12(sp)
80000128:	0a079c63          	bnez	a5,800001e0 <_ntoa_long+0x1c0>
8000012c:	0a0a9663          	bnez	s5,800001d8 <_ntoa_long+0x1b8>
80000130:	01000713          	li	a4,16
80000134:	3ce40863          	beq	s0,a4,80000504 <_ntoa_long+0x4e4>
80000138:	00200793          	li	a5,2
8000013c:	38f40863          	beq	s0,a5,800004cc <_ntoa_long+0x4ac>
80000140:	03000793          	li	a5,48
80000144:	00f10823          	sb	a5,16(sp)
80000148:	00100a93          	li	s5,1
8000014c:	0cc0006f          	j	80000218 <_ntoa_long+0x1f8>
80000150:	07412783          	lw	a5,116(sp)
80000154:	06100b13          	li	s6,97
80000158:	0107f793          	andi	a5,a5,16
8000015c:	00f12223          	sw	a5,4(sp)
80000160:	07412783          	lw	a5,116(sp)
80000164:	0207f793          	andi	a5,a5,32
80000168:	f40784e3          	beqz	a5,800000b0 <_ntoa_long+0x90>
8000016c:	04100b13          	li	s6,65
80000170:	f41ff06f          	j	800000b0 <_ntoa_long+0x90>
80000174:	07412783          	lw	a5,116(sp)
80000178:	0027fa93          	andi	s5,a5,2
8000017c:	280a9863          	bnez	s5,8000040c <_ntoa_long+0x3ec>
80000180:	00012223          	sw	zero,4(sp)
80000184:	06d12a23          	sw	a3,116(sp)
80000188:	07412783          	lw	a5,116(sp)
8000018c:	0017fb13          	andi	s6,a5,1
80000190:	1e0b8863          	beqz	s7,80000380 <_ntoa_long+0x360>
80000194:	280b0463          	beqz	s6,8000041c <_ntoa_long+0x3fc>
80000198:	00812783          	lw	a5,8(sp)
8000019c:	2a079863          	bnez	a5,8000044c <_ntoa_long+0x42c>
800001a0:	07412783          	lw	a5,116(sp)
800001a4:	00c7f713          	andi	a4,a5,12
800001a8:	2a071263          	bnez	a4,8000044c <_ntoa_long+0x42c>
800001ac:	21baf463          	bgeu	s5,s11,800003b4 <_ntoa_long+0x394>
800001b0:	02000713          	li	a4,32
800001b4:	1cea9c63          	bne	s5,a4,8000038c <_ntoa_long+0x36c>
800001b8:	237af663          	bgeu	s5,s7,800003e4 <_ntoa_long+0x3c4>
800001bc:	00412783          	lw	a5,4(sp)
800001c0:	00000b13          	li	s6,0
800001c4:	16078263          	beqz	a5,80000328 <_ntoa_long+0x308>
800001c8:	00c12783          	lw	a5,12(sp)
800001cc:	00000b13          	li	s6,0
800001d0:	02000a93          	li	s5,32
800001d4:	00079663          	bnez	a5,800001e0 <_ntoa_long+0x1c0>
800001d8:	275d8e63          	beq	s11,s5,80000454 <_ntoa_long+0x434>
800001dc:	275b8c63          	beq	s7,s5,80000454 <_ntoa_long+0x434>
800001e0:	01000713          	li	a4,16
800001e4:	2ae40663          	beq	s0,a4,80000490 <_ntoa_long+0x470>
800001e8:	00200693          	li	a3,2
800001ec:	000a8713          	mv	a4,s5
800001f0:	24d40263          	beq	s0,a3,80000434 <_ntoa_long+0x414>
800001f4:	02000793          	li	a5,32
800001f8:	12f70863          	beq	a4,a5,80000328 <_ntoa_long+0x308>
800001fc:	03010793          	addi	a5,sp,48
80000200:	00e786b3          	add	a3,a5,a4
80000204:	00170a93          	addi	s5,a4,1
80000208:	03000713          	li	a4,48
8000020c:	fee68023          	sb	a4,-32(a3)
80000210:	02000713          	li	a4,32
80000214:	10ea8a63          	beq	s5,a4,80000328 <_ntoa_long+0x308>
80000218:	00812783          	lw	a5,8(sp)
8000021c:	12078a63          	beqz	a5,80000350 <_ntoa_long+0x330>
80000220:	03010793          	addi	a5,sp,48
80000224:	01578733          	add	a4,a5,s5
80000228:	02d00793          	li	a5,45
8000022c:	001a8413          	addi	s0,s5,1
80000230:	fef70023          	sb	a5,-32(a4)
80000234:	07412783          	lw	a5,116(sp)
80000238:	0037fc93          	andi	s9,a5,3
8000023c:	0c0c9e63          	bnez	s9,80000318 <_ntoa_long+0x2f8>
80000240:	0d747c63          	bgeu	s0,s7,80000318 <_ntoa_long+0x2f8>
80000244:	00012603          	lw	a2,0(sp)
80000248:	01760c33          	add	s8,a2,s7
8000024c:	408c0c33          	sub	s8,s8,s0
80000250:	000a0693          	mv	a3,s4
80000254:	00098593          	mv	a1,s3
80000258:	02000513          	li	a0,32
8000025c:	00160493          	addi	s1,a2,1
80000260:	000900e7          	jalr	s2
80000264:	00048613          	mv	a2,s1
80000268:	fe9c14e3          	bne	s8,s1,80000250 <_ntoa_long+0x230>
8000026c:	000c0493          	mv	s1,s8
80000270:	02040a63          	beqz	s0,800002a4 <_ntoa_long+0x284>
80000274:	01010c93          	addi	s9,sp,16
80000278:	01840c33          	add	s8,s0,s8
8000027c:	018c8d33          	add	s10,s9,s8
80000280:	008c8433          	add	s0,s9,s0
80000284:	fff44503          	lbu	a0,-1(s0)
80000288:	408d0633          	sub	a2,s10,s0
8000028c:	000a0693          	mv	a3,s4
80000290:	fff40413          	addi	s0,s0,-1
80000294:	00098593          	mv	a1,s3
80000298:	000c0493          	mv	s1,s8
8000029c:	000900e7          	jalr	s2
800002a0:	fe8c92e3          	bne	s9,s0,80000284 <_ntoa_long+0x264>
800002a4:	020b0a63          	beqz	s6,800002d8 <_ntoa_long+0x2b8>
800002a8:	00012783          	lw	a5,0(sp)
800002ac:	40f48ab3          	sub	s5,s1,a5
800002b0:	037af463          	bgeu	s5,s7,800002d8 <_ntoa_long+0x2b8>
800002b4:	00048613          	mv	a2,s1
800002b8:	000a0693          	mv	a3,s4
800002bc:	00098593          	mv	a1,s3
800002c0:	02000513          	li	a0,32
800002c4:	00148493          	addi	s1,s1,1
800002c8:	000900e7          	jalr	s2
800002cc:	001a8a93          	addi	s5,s5,1
800002d0:	00048613          	mv	a2,s1
800002d4:	ff7ae2e3          	bltu	s5,s7,800002b8 <_ntoa_long+0x298>
800002d8:	06c12083          	lw	ra,108(sp)
800002dc:	06812403          	lw	s0,104(sp)
800002e0:	00048513          	mv	a0,s1
800002e4:	06012903          	lw	s2,96(sp)
800002e8:	06412483          	lw	s1,100(sp)
800002ec:	05c12983          	lw	s3,92(sp)
800002f0:	05812a03          	lw	s4,88(sp)
800002f4:	05412a83          	lw	s5,84(sp)
800002f8:	05012b03          	lw	s6,80(sp)
800002fc:	04c12b83          	lw	s7,76(sp)
80000300:	04812c03          	lw	s8,72(sp)
80000304:	04412c83          	lw	s9,68(sp)
80000308:	04012d03          	lw	s10,64(sp)
8000030c:	03c12d83          	lw	s11,60(sp)
80000310:	07010113          	addi	sp,sp,112
80000314:	00008067          	ret
80000318:	00012c03          	lw	s8,0(sp)
8000031c:	f59ff06f          	j	80000274 <_ntoa_long+0x254>
80000320:	02000713          	li	a4,32
80000324:	1eea9663          	bne	s5,a4,80000510 <_ntoa_long+0x4f0>
80000328:	07412783          	lw	a5,116(sp)
8000032c:	0037fc93          	andi	s9,a5,3
80000330:	000c8863          	beqz	s9,80000340 <_ntoa_long+0x320>
80000334:	00012c03          	lw	s8,0(sp)
80000338:	02000413          	li	s0,32
8000033c:	f39ff06f          	j	80000274 <_ntoa_long+0x254>
80000340:	02000413          	li	s0,32
80000344:	f17460e3          	bltu	s0,s7,80000244 <_ntoa_long+0x224>
80000348:	00012c03          	lw	s8,0(sp)
8000034c:	f21ff06f          	j	8000026c <_ntoa_long+0x24c>
80000350:	07412783          	lw	a5,116(sp)
80000354:	0047f713          	andi	a4,a5,4
80000358:	08071e63          	bnez	a4,800003f4 <_ntoa_long+0x3d4>
8000035c:	07412783          	lw	a5,116(sp)
80000360:	0087f713          	andi	a4,a5,8
80000364:	14071863          	bnez	a4,800004b4 <_ntoa_long+0x494>
80000368:	07412783          	lw	a5,116(sp)
8000036c:	000a8413          	mv	s0,s5
80000370:	0037fc93          	andi	s9,a5,3
80000374:	fc0c9ae3          	bnez	s9,80000348 <_ntoa_long+0x328>
80000378:	ed7466e3          	bltu	s0,s7,80000244 <_ntoa_long+0x224>
8000037c:	fcdff06f          	j	80000348 <_ntoa_long+0x328>
80000380:	03baf863          	bgeu	s5,s11,800003b0 <_ntoa_long+0x390>
80000384:	02000713          	li	a4,32
80000388:	02ea8463          	beq	s5,a4,800003b0 <_ntoa_long+0x390>
8000038c:	01010493          	addi	s1,sp,16
80000390:	03000693          	li	a3,48
80000394:	02000613          	li	a2,32
80000398:	0080006f          	j	800003a0 <_ntoa_long+0x380>
8000039c:	00ca8a63          	beq	s5,a2,800003b0 <_ntoa_long+0x390>
800003a0:	001a8a93          	addi	s5,s5,1
800003a4:	01548733          	add	a4,s1,s5
800003a8:	fed70fa3          	sb	a3,-1(a4)
800003ac:	ffbae8e3          	bltu	s5,s11,8000039c <_ntoa_long+0x37c>
800003b0:	d60b06e3          	beqz	s6,8000011c <_ntoa_long+0xfc>
800003b4:	037af863          	bgeu	s5,s7,800003e4 <_ntoa_long+0x3c4>
800003b8:	01f00713          	li	a4,31
800003bc:	e15760e3          	bltu	a4,s5,800001bc <_ntoa_long+0x19c>
800003c0:	01010493          	addi	s1,sp,16
800003c4:	03000693          	li	a3,48
800003c8:	02000613          	li	a2,32
800003cc:	0080006f          	j	800003d4 <_ntoa_long+0x3b4>
800003d0:	deca86e3          	beq	s5,a2,800001bc <_ntoa_long+0x19c>
800003d4:	001a8a93          	addi	s5,s5,1
800003d8:	01548733          	add	a4,s1,s5
800003dc:	fed70fa3          	sb	a3,-1(a4)
800003e0:	ff7a98e3          	bne	s5,s7,800003d0 <_ntoa_long+0x3b0>
800003e4:	00412783          	lw	a5,4(sp)
800003e8:	00000b13          	li	s6,0
800003ec:	d2079ce3          	bnez	a5,80000124 <_ntoa_long+0x104>
800003f0:	e21ff06f          	j	80000210 <_ntoa_long+0x1f0>
800003f4:	03010793          	addi	a5,sp,48
800003f8:	01578733          	add	a4,a5,s5
800003fc:	02b00793          	li	a5,43
80000400:	001a8413          	addi	s0,s5,1
80000404:	fef70023          	sb	a5,-32(a4)
80000408:	e2dff06f          	j	80000234 <_ntoa_long+0x214>
8000040c:	000a8b13          	mv	s6,s5
80000410:	06d12a23          	sw	a3,116(sp)
80000414:	00000a93          	li	s5,0
80000418:	e01ff06f          	j	80000218 <_ntoa_long+0x1f8>
8000041c:	d1baf0e3          	bgeu	s5,s11,8000011c <_ntoa_long+0xfc>
80000420:	02000713          	li	a4,32
80000424:	f6ea94e3          	bne	s5,a4,8000038c <_ntoa_long+0x36c>
80000428:	00412783          	lw	a5,4(sp)
8000042c:	ce079ce3          	bnez	a5,80000124 <_ntoa_long+0x104>
80000430:	ef9ff06f          	j	80000328 <_ntoa_long+0x308>
80000434:	02000693          	li	a3,32
80000438:	eeda88e3          	beq	s5,a3,80000328 <_ntoa_long+0x308>
8000043c:	01010793          	addi	a5,sp,16
80000440:	001a8713          	addi	a4,s5,1
80000444:	015787b3          	add	a5,a5,s5
80000448:	0b00006f          	j	800004f8 <_ntoa_long+0x4d8>
8000044c:	fffb8b93          	addi	s7,s7,-1
80000450:	d5dff06f          	j	800001ac <_ntoa_long+0x18c>
80000454:	fffa8713          	addi	a4,s5,-1
80000458:	08070263          	beqz	a4,800004dc <_ntoa_long+0x4bc>
8000045c:	01000693          	li	a3,16
80000460:	08d41263          	bne	s0,a3,800004e4 <_ntoa_long+0x4c4>
80000464:	07412783          	lw	a5,116(sp)
80000468:	ffea8a93          	addi	s5,s5,-2
8000046c:	0207f713          	andi	a4,a5,32
80000470:	0a071063          	bnez	a4,80000510 <_ntoa_long+0x4f0>
80000474:	000a8693          	mv	a3,s5
80000478:	01010793          	addi	a5,sp,16
8000047c:	00168713          	addi	a4,a3,1
80000480:	00d787b3          	add	a5,a5,a3
80000484:	07800693          	li	a3,120
80000488:	00d78023          	sb	a3,0(a5)
8000048c:	d69ff06f          	j	800001f4 <_ntoa_long+0x1d4>
80000490:	07412783          	lw	a5,116(sp)
80000494:	0207f713          	andi	a4,a5,32
80000498:	e80714e3          	bnez	a4,80000320 <_ntoa_long+0x300>
8000049c:	02000713          	li	a4,32
800004a0:	e8ea84e3          	beq	s5,a4,80000328 <_ntoa_long+0x308>
800004a4:	01010793          	addi	a5,sp,16
800004a8:	001a8713          	addi	a4,s5,1
800004ac:	015787b3          	add	a5,a5,s5
800004b0:	fd5ff06f          	j	80000484 <_ntoa_long+0x464>
800004b4:	03010793          	addi	a5,sp,48
800004b8:	01578733          	add	a4,a5,s5
800004bc:	02000793          	li	a5,32
800004c0:	001a8413          	addi	s0,s5,1
800004c4:	fef70023          	sb	a5,-32(a4)
800004c8:	d6dff06f          	j	80000234 <_ntoa_long+0x214>
800004cc:	06200793          	li	a5,98
800004d0:	00f10823          	sb	a5,16(sp)
800004d4:	00100713          	li	a4,1
800004d8:	d25ff06f          	j	800001fc <_ntoa_long+0x1dc>
800004dc:	01000793          	li	a5,16
800004e0:	04f40463          	beq	s0,a5,80000528 <_ntoa_long+0x508>
800004e4:	00200793          	li	a5,2
800004e8:	d0f41ae3          	bne	s0,a5,800001fc <_ntoa_long+0x1dc>
800004ec:	01010793          	addi	a5,sp,16
800004f0:	00e787b3          	add	a5,a5,a4
800004f4:	00170713          	addi	a4,a4,1
800004f8:	06200693          	li	a3,98
800004fc:	00d78023          	sb	a3,0(a5)
80000500:	cf5ff06f          	j	800001f4 <_ntoa_long+0x1d4>
80000504:	07412783          	lw	a5,116(sp)
80000508:	0207f693          	andi	a3,a5,32
8000050c:	f60686e3          	beqz	a3,80000478 <_ntoa_long+0x458>
80000510:	03010793          	addi	a5,sp,48
80000514:	015786b3          	add	a3,a5,s5
80000518:	05800793          	li	a5,88
8000051c:	001a8713          	addi	a4,s5,1
80000520:	fef68023          	sb	a5,-32(a3)
80000524:	cd1ff06f          	j	800001f4 <_ntoa_long+0x1d4>
80000528:	07412783          	lw	a5,116(sp)
8000052c:	0207f793          	andi	a5,a5,32
80000530:	00079a63          	bnez	a5,80000544 <_ntoa_long+0x524>
80000534:	07800793          	li	a5,120
80000538:	00f10823          	sb	a5,16(sp)
8000053c:	00100713          	li	a4,1
80000540:	cbdff06f          	j	800001fc <_ntoa_long+0x1dc>
80000544:	05800793          	li	a5,88
80000548:	00f10823          	sb	a5,16(sp)
8000054c:	00100713          	li	a4,1
80000550:	cadff06f          	j	800001fc <_ntoa_long+0x1dc>

80000554 <_vsnprintf>:
80000554:	f9010113          	addi	sp,sp,-112
80000558:	06812423          	sw	s0,104(sp)
8000055c:	07212023          	sw	s2,96(sp)
80000560:	05312e23          	sw	s3,92(sp)
80000564:	05412c23          	sw	s4,88(sp)
80000568:	05612823          	sw	s6,80(sp)
8000056c:	06112623          	sw	ra,108(sp)
80000570:	06912223          	sw	s1,100(sp)
80000574:	05512a23          	sw	s5,84(sp)
80000578:	05712623          	sw	s7,76(sp)
8000057c:	05812423          	sw	s8,72(sp)
80000580:	05912223          	sw	s9,68(sp)
80000584:	05a12023          	sw	s10,64(sp)
80000588:	03b12e23          	sw	s11,60(sp)
8000058c:	00058993          	mv	s3,a1
80000590:	00060913          	mv	s2,a2
80000594:	00068b13          	mv	s6,a3
80000598:	00070413          	mv	s0,a4
8000059c:	00050a13          	mv	s4,a0
800005a0:	4c058a63          	beqz	a1,80000a74 <_vsnprintf+0x520>
800005a4:	80001bb7          	lui	s7,0x80001
800005a8:	680b8793          	addi	a5,s7,1664 # 80001680 <_bss_end+0xfffffdf0>
800005ac:	00f12e23          	sw	a5,28(sp)
800005b0:	800017b7          	lui	a5,0x80001
800005b4:	800014b7          	lui	s1,0x80001
800005b8:	63478793          	addi	a5,a5,1588 # 80001634 <_bss_end+0xfffffda4>
800005bc:	00000d93          	li	s11,0
800005c0:	02500a93          	li	s5,37
800005c4:	5f048493          	addi	s1,s1,1520 # 800015f0 <_bss_end+0xfffffd60>
800005c8:	02f12023          	sw	a5,32(sp)
800005cc:	000b4503          	lbu	a0,0(s6)
800005d0:	02050463          	beqz	a0,800005f8 <_vsnprintf+0xa4>
800005d4:	001b0b13          	addi	s6,s6,1
800005d8:	07550e63          	beq	a0,s5,80000654 <_vsnprintf+0x100>
800005dc:	000d8613          	mv	a2,s11
800005e0:	00090693          	mv	a3,s2
800005e4:	00098593          	mv	a1,s3
800005e8:	000a00e7          	jalr	s4
800005ec:	000b4503          	lbu	a0,0(s6)
800005f0:	001d8d93          	addi	s11,s11,1
800005f4:	fe0510e3          	bnez	a0,800005d4 <_vsnprintf+0x80>
800005f8:	000d8613          	mv	a2,s11
800005fc:	012de463          	bltu	s11,s2,80000604 <_vsnprintf+0xb0>
80000600:	fff90613          	addi	a2,s2,-1
80000604:	00090693          	mv	a3,s2
80000608:	00098593          	mv	a1,s3
8000060c:	00000513          	li	a0,0
80000610:	000a00e7          	jalr	s4
80000614:	06c12083          	lw	ra,108(sp)
80000618:	06812403          	lw	s0,104(sp)
8000061c:	000d8513          	mv	a0,s11
80000620:	06412483          	lw	s1,100(sp)
80000624:	06012903          	lw	s2,96(sp)
80000628:	05c12983          	lw	s3,92(sp)
8000062c:	05812a03          	lw	s4,88(sp)
80000630:	05412a83          	lw	s5,84(sp)
80000634:	05012b03          	lw	s6,80(sp)
80000638:	04c12b83          	lw	s7,76(sp)
8000063c:	04812c03          	lw	s8,72(sp)
80000640:	04412c83          	lw	s9,68(sp)
80000644:	04012d03          	lw	s10,64(sp)
80000648:	03c12d83          	lw	s11,60(sp)
8000064c:	07010113          	addi	sp,sp,112
80000650:	00008067          	ret
80000654:	000b4503          	lbu	a0,0(s6)
80000658:	001b0713          	addi	a4,s6,1
8000065c:	01000593          	li	a1,16
80000660:	fe050793          	addi	a5,a0,-32
80000664:	0ff7f793          	andi	a5,a5,255
80000668:	00000693          	li	a3,0
8000066c:	00070613          	mv	a2,a4
80000670:	02f5ea63          	bltu	a1,a5,800006a4 <_vsnprintf+0x150>
80000674:	00279793          	slli	a5,a5,0x2
80000678:	009787b3          	add	a5,a5,s1
8000067c:	0007a783          	lw	a5,0(a5)
80000680:	00078067          	jr	a5
80000684:	0016e693          	ori	a3,a3,1
80000688:	00070b13          	mv	s6,a4
8000068c:	000b4503          	lbu	a0,0(s6)
80000690:	001b0713          	addi	a4,s6,1
80000694:	00070613          	mv	a2,a4
80000698:	fe050793          	addi	a5,a0,-32
8000069c:	0ff7f793          	andi	a5,a5,255
800006a0:	fcf5fae3          	bgeu	a1,a5,80000674 <_vsnprintf+0x120>
800006a4:	fd050793          	addi	a5,a0,-48
800006a8:	0ff7f793          	andi	a5,a5,255
800006ac:	00900593          	li	a1,9
800006b0:	0af5f063          	bgeu	a1,a5,80000750 <_vsnprintf+0x1fc>
800006b4:	02a00793          	li	a5,42
800006b8:	00000b93          	li	s7,0
800006bc:	14f50a63          	beq	a0,a5,80000810 <_vsnprintf+0x2bc>
800006c0:	02e00793          	li	a5,46
800006c4:	00000d13          	li	s10,0
800006c8:	0cf50a63          	beq	a0,a5,8000079c <_vsnprintf+0x248>
800006cc:	f9850793          	addi	a5,a0,-104
800006d0:	0ff7f793          	andi	a5,a5,255
800006d4:	01200713          	li	a4,18
800006d8:	0ef76e63          	bltu	a4,a5,800007d4 <_vsnprintf+0x280>
800006dc:	02012703          	lw	a4,32(sp)
800006e0:	00279793          	slli	a5,a5,0x2
800006e4:	00e787b3          	add	a5,a5,a4
800006e8:	0007a783          	lw	a5,0(a5)
800006ec:	00078067          	jr	a5
800006f0:	0026e693          	ori	a3,a3,2
800006f4:	00070b13          	mv	s6,a4
800006f8:	f95ff06f          	j	8000068c <_vsnprintf+0x138>
800006fc:	0046e693          	ori	a3,a3,4
80000700:	00070b13          	mv	s6,a4
80000704:	f89ff06f          	j	8000068c <_vsnprintf+0x138>
80000708:	0106e693          	ori	a3,a3,16
8000070c:	00070b13          	mv	s6,a4
80000710:	f7dff06f          	j	8000068c <_vsnprintf+0x138>
80000714:	0086e693          	ori	a3,a3,8
80000718:	00070b13          	mv	s6,a4
8000071c:	f71ff06f          	j	8000068c <_vsnprintf+0x138>
80000720:	001b4503          	lbu	a0,1(s6)
80000724:	1006e693          	ori	a3,a3,256
80000728:	00160b13          	addi	s6,a2,1
8000072c:	fdb50793          	addi	a5,a0,-37
80000730:	0ff7f793          	andi	a5,a5,255
80000734:	05300713          	li	a4,83
80000738:	eaf762e3          	bltu	a4,a5,800005dc <_vsnprintf+0x88>
8000073c:	01c12703          	lw	a4,28(sp)
80000740:	00279793          	slli	a5,a5,0x2
80000744:	00e787b3          	add	a5,a5,a4
80000748:	0007a783          	lw	a5,0(a5)
8000074c:	00078067          	jr	a5
80000750:	00000b93          	li	s7,0
80000754:	00900613          	li	a2,9
80000758:	00c0006f          	j	80000764 <_vsnprintf+0x210>
8000075c:	00070b13          	mv	s6,a4
80000760:	00170713          	addi	a4,a4,1
80000764:	002b9793          	slli	a5,s7,0x2
80000768:	017787b3          	add	a5,a5,s7
8000076c:	00179793          	slli	a5,a5,0x1
80000770:	00a787b3          	add	a5,a5,a0
80000774:	00074503          	lbu	a0,0(a4)
80000778:	fd078b93          	addi	s7,a5,-48
8000077c:	fd050793          	addi	a5,a0,-48
80000780:	0ff7f793          	andi	a5,a5,255
80000784:	fcf67ce3          	bgeu	a2,a5,8000075c <_vsnprintf+0x208>
80000788:	02e00793          	li	a5,46
8000078c:	002b0613          	addi	a2,s6,2
80000790:	00000d13          	li	s10,0
80000794:	00070b13          	mv	s6,a4
80000798:	f2f51ae3          	bne	a0,a5,800006cc <_vsnprintf+0x178>
8000079c:	001b4503          	lbu	a0,1(s6)
800007a0:	00900713          	li	a4,9
800007a4:	4006e693          	ori	a3,a3,1024
800007a8:	fd050793          	addi	a5,a0,-48
800007ac:	0ff7f793          	andi	a5,a5,255
800007b0:	02f77863          	bgeu	a4,a5,800007e0 <_vsnprintf+0x28c>
800007b4:	02a00793          	li	a5,42
800007b8:	2cf50463          	beq	a0,a5,80000a80 <_vsnprintf+0x52c>
800007bc:	f9850793          	addi	a5,a0,-104
800007c0:	0ff7f793          	andi	a5,a5,255
800007c4:	01200713          	li	a4,18
800007c8:	00060b13          	mv	s6,a2
800007cc:	00160613          	addi	a2,a2,1
800007d0:	f0f776e3          	bgeu	a4,a5,800006dc <_vsnprintf+0x188>
800007d4:	00060b13          	mv	s6,a2
800007d8:	f55ff06f          	j	8000072c <_vsnprintf+0x1d8>
800007dc:	000b0613          	mv	a2,s6
800007e0:	002d1793          	slli	a5,s10,0x2
800007e4:	01a788b3          	add	a7,a5,s10
800007e8:	00189893          	slli	a7,a7,0x1
800007ec:	00a888b3          	add	a7,a7,a0
800007f0:	00164503          	lbu	a0,1(a2)
800007f4:	00160b13          	addi	s6,a2,1
800007f8:	fd088d13          	addi	s10,a7,-48
800007fc:	fd050793          	addi	a5,a0,-48
80000800:	0ff7f793          	andi	a5,a5,255
80000804:	fcf77ce3          	bgeu	a4,a5,800007dc <_vsnprintf+0x288>
80000808:	00260613          	addi	a2,a2,2
8000080c:	ec1ff06f          	j	800006cc <_vsnprintf+0x178>
80000810:	00042b83          	lw	s7,0(s0)
80000814:	00440413          	addi	s0,s0,4
80000818:	240bc263          	bltz	s7,80000a5c <_vsnprintf+0x508>
8000081c:	002b0613          	addi	a2,s6,2
80000820:	001b4503          	lbu	a0,1(s6)
80000824:	00070b13          	mv	s6,a4
80000828:	e99ff06f          	j	800006c0 <_vsnprintf+0x16c>
8000082c:	00042c03          	lw	s8,0(s0)
80000830:	00440793          	addi	a5,s0,4
80000834:	02f12423          	sw	a5,40(sp)
80000838:	000c4503          	lbu	a0,0(s8)
8000083c:	260d1463          	bnez	s10,80000aa4 <_vsnprintf+0x550>
80000840:	ffe00793          	li	a5,-2
80000844:	46050c63          	beqz	a0,80000cbc <_vsnprintf+0x768>
80000848:	00178793          	addi	a5,a5,1
8000084c:	02f12223          	sw	a5,36(sp)
80000850:	00fc0633          	add	a2,s8,a5
80000854:	000c0793          	mv	a5,s8
80000858:	0080006f          	j	80000860 <_vsnprintf+0x30c>
8000085c:	00f60c63          	beq	a2,a5,80000874 <_vsnprintf+0x320>
80000860:	00178793          	addi	a5,a5,1
80000864:	0007c703          	lbu	a4,0(a5)
80000868:	fe071ae3          	bnez	a4,8000085c <_vsnprintf+0x308>
8000086c:	418787b3          	sub	a5,a5,s8
80000870:	02f12223          	sw	a5,36(sp)
80000874:	4006f413          	andi	s0,a3,1024
80000878:	00040863          	beqz	s0,80000888 <_vsnprintf+0x334>
8000087c:	02412783          	lw	a5,36(sp)
80000880:	00fd7463          	bgeu	s10,a5,80000888 <_vsnprintf+0x334>
80000884:	03a12223          	sw	s10,36(sp)
80000888:	0026f793          	andi	a5,a3,2
8000088c:	02f12623          	sw	a5,44(sp)
80000890:	2e078063          	beqz	a5,80000b70 <_vsnprintf+0x61c>
80000894:	28050863          	beqz	a0,80000b24 <_vsnprintf+0x5d0>
80000898:	000d8613          	mv	a2,s11
8000089c:	00040863          	beqz	s0,800008ac <_vsnprintf+0x358>
800008a0:	fffd0793          	addi	a5,s10,-1
800008a4:	260d0863          	beqz	s10,80000b14 <_vsnprintf+0x5c0>
800008a8:	00078d13          	mv	s10,a5
800008ac:	00090693          	mv	a3,s2
800008b0:	00098593          	mv	a1,s3
800008b4:	00160c93          	addi	s9,a2,1
800008b8:	000a00e7          	jalr	s4
800008bc:	41bc87b3          	sub	a5,s9,s11
800008c0:	00fc07b3          	add	a5,s8,a5
800008c4:	0007c503          	lbu	a0,0(a5)
800008c8:	24050863          	beqz	a0,80000b18 <_vsnprintf+0x5c4>
800008cc:	000c8613          	mv	a2,s9
800008d0:	fcdff06f          	j	8000089c <_vsnprintf+0x348>
800008d4:	00042703          	lw	a4,0(s0)
800008d8:	0216e693          	ori	a3,a3,33
800008dc:	00800793          	li	a5,8
800008e0:	00d12223          	sw	a3,4(sp)
800008e4:	00f12023          	sw	a5,0(sp)
800008e8:	000d8613          	mv	a2,s11
800008ec:	000d0893          	mv	a7,s10
800008f0:	01000813          	li	a6,16
800008f4:	00000793          	li	a5,0
800008f8:	00090693          	mv	a3,s2
800008fc:	00098593          	mv	a1,s3
80000900:	000a0513          	mv	a0,s4
80000904:	f1cff0ef          	jal	ra,80000020 <_ntoa_long>
80000908:	00440413          	addi	s0,s0,4
8000090c:	00050d93          	mv	s11,a0
80000910:	cbdff06f          	j	800005cc <_vsnprintf+0x78>
80000914:	001d8d13          	addi	s10,s11,1
80000918:	0026f693          	andi	a3,a3,2
8000091c:	00440c13          	addi	s8,s0,4
80000920:	000d0c93          	mv	s9,s10
80000924:	28068c63          	beqz	a3,80000bbc <_vsnprintf+0x668>
80000928:	00044503          	lbu	a0,0(s0)
8000092c:	000d8613          	mv	a2,s11
80000930:	00090693          	mv	a3,s2
80000934:	00098593          	mv	a1,s3
80000938:	000a00e7          	jalr	s4
8000093c:	00100793          	li	a5,1
80000940:	01bb8db3          	add	s11,s7,s11
80000944:	3177fa63          	bgeu	a5,s7,80000c58 <_vsnprintf+0x704>
80000948:	001c8793          	addi	a5,s9,1
8000094c:	000c8613          	mv	a2,s9
80000950:	00090693          	mv	a3,s2
80000954:	00078c93          	mv	s9,a5
80000958:	00098593          	mv	a1,s3
8000095c:	02000513          	li	a0,32
80000960:	000a00e7          	jalr	s4
80000964:	ff9d92e3          	bne	s11,s9,80000948 <_vsnprintf+0x3f4>
80000968:	000c0413          	mv	s0,s8
8000096c:	c61ff06f          	j	800005cc <_vsnprintf+0x78>
80000970:	07800793          	li	a5,120
80000974:	2ef50c63          	beq	a0,a5,80000c6c <_vsnprintf+0x718>
80000978:	05800793          	li	a5,88
8000097c:	12f50a63          	beq	a0,a5,80000ab0 <_vsnprintf+0x55c>
80000980:	06f00793          	li	a5,111
80000984:	2af50063          	beq	a0,a5,80000c24 <_vsnprintf+0x6d0>
80000988:	06200793          	li	a5,98
8000098c:	2cf50c63          	beq	a0,a5,80000c64 <_vsnprintf+0x710>
80000990:	06900713          	li	a4,105
80000994:	fef6f613          	andi	a2,a3,-17
80000998:	4006f793          	andi	a5,a3,1024
8000099c:	36e51263          	bne	a0,a4,80000d00 <_vsnprintf+0x7ac>
800009a0:	26079e63          	bnez	a5,80000c1c <_vsnprintf+0x6c8>
800009a4:	2006f693          	andi	a3,a3,512
800009a8:	00a00813          	li	a6,10
800009ac:	c20690e3          	bnez	a3,800005cc <_vsnprintf+0x78>
800009b0:	10067793          	andi	a5,a2,256
800009b4:	00440c13          	addi	s8,s0,4
800009b8:	2c079463          	bnez	a5,80000c80 <_vsnprintf+0x72c>
800009bc:	04067793          	andi	a5,a2,64
800009c0:	28079263          	bnez	a5,80000c44 <_vsnprintf+0x6f0>
800009c4:	08067793          	andi	a5,a2,128
800009c8:	2e078e63          	beqz	a5,80000cc4 <_vsnprintf+0x770>
800009cc:	00041783          	lh	a5,0(s0)
800009d0:	41f7d693          	srai	a3,a5,0x1f
800009d4:	00f6c733          	xor	a4,a3,a5
800009d8:	40d70733          	sub	a4,a4,a3
800009dc:	00c12223          	sw	a2,4(sp)
800009e0:	01712023          	sw	s7,0(sp)
800009e4:	000d0893          	mv	a7,s10
800009e8:	01f7d793          	srli	a5,a5,0x1f
800009ec:	000d8613          	mv	a2,s11
800009f0:	00090693          	mv	a3,s2
800009f4:	00098593          	mv	a1,s3
800009f8:	000a0513          	mv	a0,s4
800009fc:	e24ff0ef          	jal	ra,80000020 <_ntoa_long>
80000a00:	00050d93          	mv	s11,a0
80000a04:	000c0413          	mv	s0,s8
80000a08:	bc5ff06f          	j	800005cc <_vsnprintf+0x78>
80000a0c:	000d8613          	mv	a2,s11
80000a10:	00090693          	mv	a3,s2
80000a14:	00098593          	mv	a1,s3
80000a18:	02500513          	li	a0,37
80000a1c:	001d8d93          	addi	s11,s11,1
80000a20:	000a00e7          	jalr	s4
80000a24:	ba9ff06f          	j	800005cc <_vsnprintf+0x78>
80000a28:	001b4503          	lbu	a0,1(s6)
80000a2c:	06c00793          	li	a5,108
80000a30:	cef51ae3          	bne	a0,a5,80000724 <_vsnprintf+0x1d0>
80000a34:	002b4503          	lbu	a0,2(s6)
80000a38:	3006e693          	ori	a3,a3,768
80000a3c:	003b0b13          	addi	s6,s6,3
80000a40:	cedff06f          	j	8000072c <_vsnprintf+0x1d8>
80000a44:	001b4503          	lbu	a0,1(s6)
80000a48:	06800793          	li	a5,104
80000a4c:	10f50a63          	beq	a0,a5,80000b60 <_vsnprintf+0x60c>
80000a50:	0806e693          	ori	a3,a3,128
80000a54:	00160b13          	addi	s6,a2,1
80000a58:	cd5ff06f          	j	8000072c <_vsnprintf+0x1d8>
80000a5c:	002b0613          	addi	a2,s6,2
80000a60:	001b4503          	lbu	a0,1(s6)
80000a64:	0026e693          	ori	a3,a3,2
80000a68:	41700bb3          	neg	s7,s7
80000a6c:	00070b13          	mv	s6,a4
80000a70:	c51ff06f          	j	800006c0 <_vsnprintf+0x16c>
80000a74:	80000a37          	lui	s4,0x80000
80000a78:	01ca0a13          	addi	s4,s4,28 # 8000001c <_bss_end+0xffffe78c>
80000a7c:	b29ff06f          	j	800005a4 <_vsnprintf+0x50>
80000a80:	00042d03          	lw	s10,0(s0)
80000a84:	002b4503          	lbu	a0,2(s6)
80000a88:	003b0613          	addi	a2,s6,3
80000a8c:	fffd4793          	not	a5,s10
80000a90:	41f7d793          	srai	a5,a5,0x1f
80000a94:	00fd7d33          	and	s10,s10,a5
80000a98:	00440413          	addi	s0,s0,4
80000a9c:	002b0b13          	addi	s6,s6,2
80000aa0:	c2dff06f          	j	800006cc <_vsnprintf+0x178>
80000aa4:	20050c63          	beqz	a0,80000cbc <_vsnprintf+0x768>
80000aa8:	fffd0793          	addi	a5,s10,-1
80000aac:	d9dff06f          	j	80000848 <_vsnprintf+0x2f4>
80000ab0:	ff36f613          	andi	a2,a3,-13
80000ab4:	4006f793          	andi	a5,a3,1024
80000ab8:	02066613          	ori	a2,a2,32
80000abc:	14078a63          	beqz	a5,80000c10 <_vsnprintf+0x6bc>
80000ac0:	01000813          	li	a6,16
80000ac4:	ffe67613          	andi	a2,a2,-2
80000ac8:	06900793          	li	a5,105
80000acc:	20067693          	andi	a3,a2,512
80000ad0:	ecf50ee3          	beq	a0,a5,800009ac <_vsnprintf+0x458>
80000ad4:	06400793          	li	a5,100
80000ad8:	ecf50ae3          	beq	a0,a5,800009ac <_vsnprintf+0x458>
80000adc:	ae0698e3          	bnez	a3,800005cc <_vsnprintf+0x78>
80000ae0:	10067793          	andi	a5,a2,256
80000ae4:	00440c13          	addi	s8,s0,4
80000ae8:	1a079e63          	bnez	a5,80000ca4 <_vsnprintf+0x750>
80000aec:	04067793          	andi	a5,a2,64
80000af0:	16079063          	bnez	a5,80000c50 <_vsnprintf+0x6fc>
80000af4:	08067793          	andi	a5,a2,128
80000af8:	1e078063          	beqz	a5,80000cd8 <_vsnprintf+0x784>
80000afc:	00045703          	lhu	a4,0(s0)
80000b00:	00c12223          	sw	a2,4(sp)
80000b04:	01712023          	sw	s7,0(sp)
80000b08:	000d0893          	mv	a7,s10
80000b0c:	00000793          	li	a5,0
80000b10:	eddff06f          	j	800009ec <_vsnprintf+0x498>
80000b14:	00060c93          	mv	s9,a2
80000b18:	02c12783          	lw	a5,44(sp)
80000b1c:	02078c63          	beqz	a5,80000b54 <_vsnprintf+0x600>
80000b20:	000c8d93          	mv	s11,s9
80000b24:	02412703          	lw	a4,36(sp)
80000b28:	09777663          	bgeu	a4,s7,80000bb4 <_vsnprintf+0x660>
80000b2c:	01bb87b3          	add	a5,s7,s11
80000b30:	40e78cb3          	sub	s9,a5,a4
80000b34:	001d8793          	addi	a5,s11,1
80000b38:	000d8613          	mv	a2,s11
80000b3c:	00090693          	mv	a3,s2
80000b40:	00078d93          	mv	s11,a5
80000b44:	00098593          	mv	a1,s3
80000b48:	02000513          	li	a0,32
80000b4c:	000a00e7          	jalr	s4
80000b50:	ffbc92e3          	bne	s9,s11,80000b34 <_vsnprintf+0x5e0>
80000b54:	02812403          	lw	s0,40(sp)
80000b58:	000c8d93          	mv	s11,s9
80000b5c:	a71ff06f          	j	800005cc <_vsnprintf+0x78>
80000b60:	002b4503          	lbu	a0,2(s6)
80000b64:	0c06e693          	ori	a3,a3,192
80000b68:	003b0b13          	addi	s6,s6,3
80000b6c:	bc1ff06f          	j	8000072c <_vsnprintf+0x1d8>
80000b70:	02412703          	lw	a4,36(sp)
80000b74:	00170793          	addi	a5,a4,1
80000b78:	17777a63          	bgeu	a4,s7,80000cec <_vsnprintf+0x798>
80000b7c:	01bb87b3          	add	a5,s7,s11
80000b80:	40e78cb3          	sub	s9,a5,a4
80000b84:	001d8793          	addi	a5,s11,1
80000b88:	000d8613          	mv	a2,s11
80000b8c:	00090693          	mv	a3,s2
80000b90:	00078d93          	mv	s11,a5
80000b94:	00098593          	mv	a1,s3
80000b98:	02000513          	li	a0,32
80000b9c:	000a00e7          	jalr	s4
80000ba0:	ffbc92e3          	bne	s9,s11,80000b84 <_vsnprintf+0x630>
80000ba4:	000c4503          	lbu	a0,0(s8)
80000ba8:	001b8793          	addi	a5,s7,1
80000bac:	02f12223          	sw	a5,36(sp)
80000bb0:	ce0514e3          	bnez	a0,80000898 <_vsnprintf+0x344>
80000bb4:	000d8c93          	mv	s9,s11
80000bb8:	f9dff06f          	j	80000b54 <_vsnprintf+0x600>
80000bbc:	00100793          	li	a5,1
80000bc0:	1377f063          	bgeu	a5,s7,80000ce0 <_vsnprintf+0x78c>
80000bc4:	fffd8c93          	addi	s9,s11,-1
80000bc8:	017c8cb3          	add	s9,s9,s7
80000bcc:	0080006f          	j	80000bd4 <_vsnprintf+0x680>
80000bd0:	001d0d13          	addi	s10,s10,1
80000bd4:	000d8613          	mv	a2,s11
80000bd8:	00090693          	mv	a3,s2
80000bdc:	00098593          	mv	a1,s3
80000be0:	02000513          	li	a0,32
80000be4:	000d0d93          	mv	s11,s10
80000be8:	000a00e7          	jalr	s4
80000bec:	ff9d12e3          	bne	s10,s9,80000bd0 <_vsnprintf+0x67c>
80000bf0:	001d0d93          	addi	s11,s10,1
80000bf4:	00044503          	lbu	a0,0(s0)
80000bf8:	00090693          	mv	a3,s2
80000bfc:	000c8613          	mv	a2,s9
80000c00:	00098593          	mv	a1,s3
80000c04:	000a00e7          	jalr	s4
80000c08:	000c0413          	mv	s0,s8
80000c0c:	9c1ff06f          	j	800005cc <_vsnprintf+0x78>
80000c10:	2006f693          	andi	a3,a3,512
80000c14:	01000813          	li	a6,16
80000c18:	ec5ff06f          	j	80000adc <_vsnprintf+0x588>
80000c1c:	00a00813          	li	a6,10
80000c20:	ea5ff06f          	j	80000ac4 <_vsnprintf+0x570>
80000c24:	00800813          	li	a6,8
80000c28:	00068613          	mv	a2,a3
80000c2c:	06400713          	li	a4,100
80000c30:	40067793          	andi	a5,a2,1024
80000c34:	0ce51263          	bne	a0,a4,80000cf8 <_vsnprintf+0x7a4>
80000c38:	20067693          	andi	a3,a2,512
80000c3c:	d60788e3          	beqz	a5,800009ac <_vsnprintf+0x458>
80000c40:	e85ff06f          	j	80000ac4 <_vsnprintf+0x570>
80000c44:	00044783          	lbu	a5,0(s0)
80000c48:	00078713          	mv	a4,a5
80000c4c:	d91ff06f          	j	800009dc <_vsnprintf+0x488>
80000c50:	00044703          	lbu	a4,0(s0)
80000c54:	eadff06f          	j	80000b00 <_vsnprintf+0x5ac>
80000c58:	000d0d93          	mv	s11,s10
80000c5c:	000c0413          	mv	s0,s8
80000c60:	96dff06f          	j	800005cc <_vsnprintf+0x78>
80000c64:	00200813          	li	a6,2
80000c68:	fc1ff06f          	j	80000c28 <_vsnprintf+0x6d4>
80000c6c:	4006f793          	andi	a5,a3,1024
80000c70:	01000813          	li	a6,16
80000c74:	ff36f613          	andi	a2,a3,-13
80000c78:	e40796e3          	bnez	a5,80000ac4 <_vsnprintf+0x570>
80000c7c:	e4dff06f          	j	80000ac8 <_vsnprintf+0x574>
80000c80:	00042783          	lw	a5,0(s0)
80000c84:	000d0893          	mv	a7,s10
80000c88:	00c12223          	sw	a2,4(sp)
80000c8c:	41f7d713          	srai	a4,a5,0x1f
80000c90:	00f746b3          	xor	a3,a4,a5
80000c94:	01712023          	sw	s7,0(sp)
80000c98:	01f7d793          	srli	a5,a5,0x1f
80000c9c:	40e68733          	sub	a4,a3,a4
80000ca0:	d4dff06f          	j	800009ec <_vsnprintf+0x498>
80000ca4:	00042703          	lw	a4,0(s0)
80000ca8:	000d0893          	mv	a7,s10
80000cac:	00c12223          	sw	a2,4(sp)
80000cb0:	01712023          	sw	s7,0(sp)
80000cb4:	00000793          	li	a5,0
80000cb8:	d35ff06f          	j	800009ec <_vsnprintf+0x498>
80000cbc:	02012223          	sw	zero,36(sp)
80000cc0:	bb5ff06f          	j	80000874 <_vsnprintf+0x320>
80000cc4:	00042783          	lw	a5,0(s0)
80000cc8:	41f7d693          	srai	a3,a5,0x1f
80000ccc:	00f6c733          	xor	a4,a3,a5
80000cd0:	40d70733          	sub	a4,a4,a3
80000cd4:	d09ff06f          	j	800009dc <_vsnprintf+0x488>
80000cd8:	00042703          	lw	a4,0(s0)
80000cdc:	e25ff06f          	j	80000b00 <_vsnprintf+0x5ac>
80000ce0:	000d8c93          	mv	s9,s11
80000ce4:	000d0d93          	mv	s11,s10
80000ce8:	f0dff06f          	j	80000bf4 <_vsnprintf+0x6a0>
80000cec:	02f12223          	sw	a5,36(sp)
80000cf0:	ba0514e3          	bnez	a0,80000898 <_vsnprintf+0x344>
80000cf4:	ec1ff06f          	j	80000bb4 <_vsnprintf+0x660>
80000cf8:	00060693          	mv	a3,a2
80000cfc:	f79ff06f          	j	80000c74 <_vsnprintf+0x720>
80000d00:	00a00813          	li	a6,10
80000d04:	f29ff06f          	j	80000c2c <_vsnprintf+0x6d8>

80000d08 <_out_char>:
80000d08:	00051463          	bnez	a0,80000d10 <_out_char+0x8>
80000d0c:	00008067          	ret
80000d10:	1ac0006f          	j	80000ebc <_putchar>

80000d14 <_out_fct>:
80000d14:	00050863          	beqz	a0,80000d24 <_out_fct+0x10>
80000d18:	0005a303          	lw	t1,0(a1)
80000d1c:	0045a583          	lw	a1,4(a1)
80000d20:	00030067          	jr	t1
80000d24:	00008067          	ret

80000d28 <printf_>:
80000d28:	fc010113          	addi	sp,sp,-64
80000d2c:	02410313          	addi	t1,sp,36
80000d30:	02d12623          	sw	a3,44(sp)
80000d34:	00050693          	mv	a3,a0
80000d38:	80001537          	lui	a0,0x80001
80000d3c:	02b12223          	sw	a1,36(sp)
80000d40:	02c12423          	sw	a2,40(sp)
80000d44:	02e12823          	sw	a4,48(sp)
80000d48:	00810593          	addi	a1,sp,8
80000d4c:	00030713          	mv	a4,t1
80000d50:	fff00613          	li	a2,-1
80000d54:	d0850513          	addi	a0,a0,-760 # 80000d08 <_bss_end+0xfffff478>
80000d58:	00112e23          	sw	ra,28(sp)
80000d5c:	02f12a23          	sw	a5,52(sp)
80000d60:	03012c23          	sw	a6,56(sp)
80000d64:	03112e23          	sw	a7,60(sp)
80000d68:	00612623          	sw	t1,12(sp)
80000d6c:	fe8ff0ef          	jal	ra,80000554 <_vsnprintf>
80000d70:	01c12083          	lw	ra,28(sp)
80000d74:	04010113          	addi	sp,sp,64
80000d78:	00008067          	ret

80000d7c <sprintf_>:
80000d7c:	fc010113          	addi	sp,sp,-64
80000d80:	02810313          	addi	t1,sp,40
80000d84:	02d12623          	sw	a3,44(sp)
80000d88:	00058693          	mv	a3,a1
80000d8c:	00050593          	mv	a1,a0
80000d90:	80000537          	lui	a0,0x80000
80000d94:	02c12423          	sw	a2,40(sp)
80000d98:	02e12823          	sw	a4,48(sp)
80000d9c:	fff00613          	li	a2,-1
80000da0:	00030713          	mv	a4,t1
80000da4:	00c50513          	addi	a0,a0,12 # 8000000c <_bss_end+0xffffe77c>
80000da8:	00112e23          	sw	ra,28(sp)
80000dac:	02f12a23          	sw	a5,52(sp)
80000db0:	03012c23          	sw	a6,56(sp)
80000db4:	03112e23          	sw	a7,60(sp)
80000db8:	00612623          	sw	t1,12(sp)
80000dbc:	f98ff0ef          	jal	ra,80000554 <_vsnprintf>
80000dc0:	01c12083          	lw	ra,28(sp)
80000dc4:	04010113          	addi	sp,sp,64
80000dc8:	00008067          	ret

80000dcc <snprintf_>:
80000dcc:	fc010113          	addi	sp,sp,-64
80000dd0:	02c10313          	addi	t1,sp,44
80000dd4:	02d12623          	sw	a3,44(sp)
80000dd8:	00060693          	mv	a3,a2
80000ddc:	00058613          	mv	a2,a1
80000de0:	00050593          	mv	a1,a0
80000de4:	80000537          	lui	a0,0x80000
80000de8:	02e12823          	sw	a4,48(sp)
80000dec:	00c50513          	addi	a0,a0,12 # 8000000c <_bss_end+0xffffe77c>
80000df0:	00030713          	mv	a4,t1
80000df4:	00112e23          	sw	ra,28(sp)
80000df8:	02f12a23          	sw	a5,52(sp)
80000dfc:	03012c23          	sw	a6,56(sp)
80000e00:	03112e23          	sw	a7,60(sp)
80000e04:	00612623          	sw	t1,12(sp)
80000e08:	f4cff0ef          	jal	ra,80000554 <_vsnprintf>
80000e0c:	01c12083          	lw	ra,28(sp)
80000e10:	04010113          	addi	sp,sp,64
80000e14:	00008067          	ret

80000e18 <vprintf_>:
80000e18:	fe010113          	addi	sp,sp,-32
80000e1c:	00050693          	mv	a3,a0
80000e20:	80001537          	lui	a0,0x80001
80000e24:	00058713          	mv	a4,a1
80000e28:	fff00613          	li	a2,-1
80000e2c:	00c10593          	addi	a1,sp,12
80000e30:	d0850513          	addi	a0,a0,-760 # 80000d08 <_bss_end+0xfffff478>
80000e34:	00112e23          	sw	ra,28(sp)
80000e38:	f1cff0ef          	jal	ra,80000554 <_vsnprintf>
80000e3c:	01c12083          	lw	ra,28(sp)
80000e40:	02010113          	addi	sp,sp,32
80000e44:	00008067          	ret

80000e48 <vsnprintf_>:
80000e48:	00068713          	mv	a4,a3
80000e4c:	00060693          	mv	a3,a2
80000e50:	00058613          	mv	a2,a1
80000e54:	00050593          	mv	a1,a0
80000e58:	80000537          	lui	a0,0x80000
80000e5c:	00c50513          	addi	a0,a0,12 # 8000000c <_bss_end+0xffffe77c>
80000e60:	ef4ff06f          	j	80000554 <_vsnprintf>

80000e64 <fctprintf>:
80000e64:	fc010113          	addi	sp,sp,-64
80000e68:	02c10313          	addi	t1,sp,44
80000e6c:	00a12423          	sw	a0,8(sp)
80000e70:	80001537          	lui	a0,0x80001
80000e74:	02d12623          	sw	a3,44(sp)
80000e78:	02e12823          	sw	a4,48(sp)
80000e7c:	00b12623          	sw	a1,12(sp)
80000e80:	00060693          	mv	a3,a2
80000e84:	00810593          	addi	a1,sp,8
80000e88:	00030713          	mv	a4,t1
80000e8c:	fff00613          	li	a2,-1
80000e90:	d1450513          	addi	a0,a0,-748 # 80000d14 <_bss_end+0xfffff484>
80000e94:	00112e23          	sw	ra,28(sp)
80000e98:	02f12a23          	sw	a5,52(sp)
80000e9c:	03012c23          	sw	a6,56(sp)
80000ea0:	03112e23          	sw	a7,60(sp)
80000ea4:	00612223          	sw	t1,4(sp)
80000ea8:	eacff0ef          	jal	ra,80000554 <_vsnprintf>
80000eac:	01c12083          	lw	ra,28(sp)
80000eb0:	04010113          	addi	sp,sp,64
80000eb4:	00008067          	ret

80000eb8 <init_uart>:
80000eb8:	00008067          	ret

80000ebc <_putchar>:
80000ebc:	10000737          	lui	a4,0x10000
80000ec0:	00574783          	lbu	a5,5(a4) # 10000005 <RAM_BASE-0x6ffffffb>
80000ec4:	0207f793          	andi	a5,a5,32
80000ec8:	fe078ce3          	beqz	a5,80000ec0 <_putchar+0x4>
80000ecc:	00a70023          	sb	a0,0(a4)
80000ed0:	00008067          	ret

80000ed4 <get_node_addr>:
80000ed4:	00058e63          	beqz	a1,80000ef0 <get_node_addr+0x1c>
80000ed8:	200007b7          	lui	a5,0x20000
80000edc:	00f51513          	slli	a0,a0,0xf
80000ee0:	00f50533          	add	a0,a0,a5
80000ee4:	00259593          	slli	a1,a1,0x2
80000ee8:	00b50533          	add	a0,a0,a1
80000eec:	00008067          	ret
80000ef0:	00000513          	li	a0,0
80000ef4:	00008067          	ret

80000ef8 <get_nexthop_ip_addr>:
80000ef8:	202007b7          	lui	a5,0x20200
80000efc:	00351513          	slli	a0,a0,0x3
80000f00:	00f50533          	add	a0,a0,a5
80000f04:	00008067          	ret

80000f08 <get_nexthop_port_addr>:
80000f08:	202007b7          	lui	a5,0x20200
80000f0c:	00478793          	addi	a5,a5,4 # 20200004 <RAM_BASE-0x5fdffffc>
80000f10:	00351513          	slli	a0,a0,0x3
80000f14:	00f50533          	add	a0,a0,a5
80000f18:	00008067          	ret

80000f1c <parse_lc>:
80000f1c:	01355513          	srli	a0,a0,0x13
80000f20:	00008067          	ret

80000f24 <parse_rc>:
80000f24:	00d51513          	slli	a0,a0,0xd
80000f28:	01355513          	srli	a0,a0,0x13
80000f2c:	00008067          	ret

80000f30 <parse_nexthop>:
80000f30:	03f57513          	andi	a0,a0,63
80000f34:	00008067          	ret

80000f38 <set_lc>:
80000f38:	00052783          	lw	a5,0(a0)
80000f3c:	01359593          	slli	a1,a1,0x13
80000f40:	00d79793          	slli	a5,a5,0xd
80000f44:	00d7d793          	srli	a5,a5,0xd
80000f48:	00b7e7b3          	or	a5,a5,a1
80000f4c:	00f52023          	sw	a5,0(a0)
80000f50:	00008067          	ret

80000f54 <set_rc>:
80000f54:	00052783          	lw	a5,0(a0)
80000f58:	fff80737          	lui	a4,0xfff80
80000f5c:	03f70713          	addi	a4,a4,63 # fff8003f <_bss_end+0x7ff7e7af>
80000f60:	00e7f7b3          	and	a5,a5,a4
80000f64:	00080737          	lui	a4,0x80
80000f68:	00659593          	slli	a1,a1,0x6
80000f6c:	fc070713          	addi	a4,a4,-64 # 7ffc0 <RAM_BASE-0x7ff80040>
80000f70:	00e5f5b3          	and	a1,a1,a4
80000f74:	00b7e7b3          	or	a5,a5,a1
80000f78:	00f52023          	sw	a5,0(a0)
80000f7c:	00008067          	ret

80000f80 <set_nexthop>:
80000f80:	00052783          	lw	a5,0(a0)
80000f84:	03f5f593          	andi	a1,a1,63
80000f88:	fc07f793          	andi	a5,a5,-64
80000f8c:	00b7e7b3          	or	a5,a5,a1
80000f90:	00f52023          	sw	a5,0(a0)
80000f94:	00008067          	ret

80000f98 <parse_node>:
80000f98:	00052683          	lw	a3,0(a0)
80000f9c:	e00007b7          	lui	a5,0xe0000
80000fa0:	00f50533          	add	a0,a0,a5
80000fa4:	00f55513          	srli	a0,a0,0xf
80000fa8:	00d69793          	slli	a5,a3,0xd
80000fac:	0136d713          	srli	a4,a3,0x13
80000fb0:	0137d793          	srli	a5,a5,0x13
80000fb4:	00150513          	addi	a0,a0,1
80000fb8:	04070263          	beqz	a4,80000ffc <parse_node+0x64>
80000fbc:	20000637          	lui	a2,0x20000
80000fc0:	00271713          	slli	a4,a4,0x2
80000fc4:	00c70733          	add	a4,a4,a2
80000fc8:	00f51613          	slli	a2,a0,0xf
80000fcc:	00c70733          	add	a4,a4,a2
80000fd0:	00e5a023          	sw	a4,0(a1)
80000fd4:	02078a63          	beqz	a5,80001008 <parse_node+0x70>
80000fd8:	00279793          	slli	a5,a5,0x2
80000fdc:	20000737          	lui	a4,0x20000
80000fe0:	00e787b3          	add	a5,a5,a4
80000fe4:	00f51513          	slli	a0,a0,0xf
80000fe8:	00a78533          	add	a0,a5,a0
80000fec:	03f6f693          	andi	a3,a3,63
80000ff0:	00a5a223          	sw	a0,4(a1)
80000ff4:	00d5a423          	sw	a3,8(a1)
80000ff8:	00008067          	ret
80000ffc:	00000713          	li	a4,0
80001000:	00e5a023          	sw	a4,0(a1)
80001004:	fc079ae3          	bnez	a5,80000fd8 <parse_node+0x40>
80001008:	00000513          	li	a0,0
8000100c:	03f6f693          	andi	a3,a3,63
80001010:	00a5a223          	sw	a0,4(a1)
80001014:	00d5a423          	sw	a3,8(a1)
80001018:	00008067          	ret

8000101c <insert>:
8000101c:	fc010113          	addi	sp,sp,-64
80001020:	03312623          	sw	s3,44(sp)
80001024:	00452983          	lw	s3,4(a0)
80001028:	03212823          	sw	s2,48(sp)
8000102c:	03412423          	sw	s4,40(sp)
80001030:	02112e23          	sw	ra,60(sp)
80001034:	02812c23          	sw	s0,56(sp)
80001038:	02912a23          	sw	s1,52(sp)
8000103c:	03512223          	sw	s5,36(sp)
80001040:	03612023          	sw	s6,32(sp)
80001044:	01712e23          	sw	s7,28(sp)
80001048:	01812c23          	sw	s8,24(sp)
8000104c:	01912a23          	sw	s9,20(sp)
80001050:	01a12823          	sw	s10,16(sp)
80001054:	00852a03          	lw	s4,8(a0)
80001058:	00c52903          	lw	s2,12(a0)
8000105c:	1a098263          	beqz	s3,80001200 <insert+0x1e4>
80001060:	00080b37          	lui	s6,0x80
80001064:	80002d37          	lui	s10,0x80002
80001068:	200004b7          	lui	s1,0x20000
8000106c:	fff80bb7          	lui	s7,0xfff80
80001070:	fffb0c93          	addi	s9,s6,-1 # 7ffff <RAM_BASE-0x7ff80001>
80001074:	00052a83          	lw	s5,0(a0)
80001078:	800d0d13          	addi	s10,s10,-2048 # 80001800 <_bss_end+0xffffff70>
8000107c:	00000413          	li	s0,0
80001080:	00448493          	addi	s1,s1,4 # 20000004 <RAM_BASE-0x5ffffffc>
80001084:	20000c37          	lui	s8,0x20000
80001088:	fc0b0b13          	addi	s6,s6,-64
8000108c:	03fb8b93          	addi	s7,s7,63 # fff8003f <_bss_end+0x7ff7e7af>
80001090:	0180006f          	j	800010a8 <insert+0x8c>
80001094:	00812783          	lw	a5,8(sp)
80001098:	0a078c63          	beqz	a5,80001150 <insert+0x134>
8000109c:	00078493          	mv	s1,a5
800010a0:	004d0d13          	addi	s10,s10,4
800010a4:	06898663          	beq	s3,s0,80001110 <insert+0xf4>
800010a8:	00410593          	addi	a1,sp,4
800010ac:	00048513          	mv	a0,s1
800010b0:	ee9ff0ef          	jal	ra,80000f98 <parse_node>
800010b4:	008ad7b3          	srl	a5,s5,s0
800010b8:	0017f793          	andi	a5,a5,1
800010bc:	00140413          	addi	s0,s0,1
800010c0:	fc079ae3          	bnez	a5,80001094 <insert+0x78>
800010c4:	00412783          	lw	a5,4(sp)
800010c8:	fc079ae3          	bnez	a5,8000109c <insert+0x80>
800010cc:	000d2703          	lw	a4,0(s10)
800010d0:	00170713          	addi	a4,a4,1 # 20000001 <RAM_BASE-0x5fffffff>
800010d4:	00ed2023          	sw	a4,0(s10)
800010d8:	00070a63          	beqz	a4,800010ec <insert+0xd0>
800010dc:	00f41793          	slli	a5,s0,0xf
800010e0:	018787b3          	add	a5,a5,s8
800010e4:	00271693          	slli	a3,a4,0x2
800010e8:	00d787b3          	add	a5,a5,a3
800010ec:	0004a683          	lw	a3,0(s1)
800010f0:	01371713          	slli	a4,a4,0x13
800010f4:	00f12223          	sw	a5,4(sp)
800010f8:	0196f6b3          	and	a3,a3,s9
800010fc:	00e6e733          	or	a4,a3,a4
80001100:	00e4a023          	sw	a4,0(s1)
80001104:	004d0d13          	addi	s10,s10,4
80001108:	00078493          	mv	s1,a5
8000110c:	f8899ee3          	bne	s3,s0,800010a8 <insert+0x8c>
80001110:	800025b7          	lui	a1,0x80002
80001114:	8805a603          	lw	a2,-1920(a1) # 80001880 <_bss_end+0xfffffff0>
80001118:	202007b7          	lui	a5,0x20200
8000111c:	0ec05863          	blez	a2,8000120c <insert+0x1f0>
80001120:	00878793          	addi	a5,a5,8 # 20200008 <RAM_BASE-0x5fdffff8>
80001124:	00100713          	li	a4,1
80001128:	0100006f          	j	80001138 <insert+0x11c>
8000112c:	00170713          	addi	a4,a4,1
80001130:	00878793          	addi	a5,a5,8
80001134:	04e64e63          	blt	a2,a4,80001190 <insert+0x174>
80001138:	0007a683          	lw	a3,0(a5)
8000113c:	ff2698e3          	bne	a3,s2,8000112c <insert+0x110>
80001140:	0047a683          	lw	a3,4(a5)
80001144:	ff4694e3          	bne	a3,s4,8000112c <insert+0x110>
80001148:	03f77713          	andi	a4,a4,63
8000114c:	06c0006f          	j	800011b8 <insert+0x19c>
80001150:	000d2703          	lw	a4,0(s10)
80001154:	00170713          	addi	a4,a4,1
80001158:	00ed2023          	sw	a4,0(s10)
8000115c:	00070a63          	beqz	a4,80001170 <insert+0x154>
80001160:	00f41793          	slli	a5,s0,0xf
80001164:	018787b3          	add	a5,a5,s8
80001168:	00271693          	slli	a3,a4,0x2
8000116c:	00d787b3          	add	a5,a5,a3
80001170:	0004a683          	lw	a3,0(s1)
80001174:	00671713          	slli	a4,a4,0x6
80001178:	01677733          	and	a4,a4,s6
8000117c:	0176f6b3          	and	a3,a3,s7
80001180:	00f12423          	sw	a5,8(sp)
80001184:	00d76733          	or	a4,a4,a3
80001188:	00e4a023          	sw	a4,0(s1)
8000118c:	f11ff06f          	j	8000109c <insert+0x80>
80001190:	202006b7          	lui	a3,0x20200
80001194:	00371793          	slli	a5,a4,0x3
80001198:	00468513          	addi	a0,a3,4 # 20200004 <RAM_BASE-0x5fdffffc>
8000119c:	03f77713          	andi	a4,a4,63
800011a0:	00d786b3          	add	a3,a5,a3
800011a4:	00a787b3          	add	a5,a5,a0
800011a8:	00160613          	addi	a2,a2,1 # 20000001 <RAM_BASE-0x5fffffff>
800011ac:	0126a023          	sw	s2,0(a3)
800011b0:	88c5a023          	sw	a2,-1920(a1)
800011b4:	0147a023          	sw	s4,0(a5)
800011b8:	0004a783          	lw	a5,0(s1)
800011bc:	03c12083          	lw	ra,60(sp)
800011c0:	03812403          	lw	s0,56(sp)
800011c4:	fc07f793          	andi	a5,a5,-64
800011c8:	00e7e733          	or	a4,a5,a4
800011cc:	00e4a023          	sw	a4,0(s1)
800011d0:	03012903          	lw	s2,48(sp)
800011d4:	03412483          	lw	s1,52(sp)
800011d8:	02c12983          	lw	s3,44(sp)
800011dc:	02812a03          	lw	s4,40(sp)
800011e0:	02412a83          	lw	s5,36(sp)
800011e4:	02012b03          	lw	s6,32(sp)
800011e8:	01c12b83          	lw	s7,28(sp)
800011ec:	01812c03          	lw	s8,24(sp)
800011f0:	01412c83          	lw	s9,20(sp)
800011f4:	01012d03          	lw	s10,16(sp)
800011f8:	04010113          	addi	sp,sp,64
800011fc:	00008067          	ret
80001200:	200004b7          	lui	s1,0x20000
80001204:	00448493          	addi	s1,s1,4 # 20000004 <RAM_BASE-0x5ffffffc>
80001208:	f09ff06f          	j	80001110 <insert+0xf4>
8000120c:	00878693          	addi	a3,a5,8
80001210:	00100713          	li	a4,1
80001214:	00c78793          	addi	a5,a5,12
80001218:	f91ff06f          	j	800011a8 <insert+0x18c>

8000121c <remove>:
8000121c:	f5010113          	addi	sp,sp,-176
80001220:	0b212023          	sw	s2,160(sp)
80001224:	09312e23          	sw	s3,156(sp)
80001228:	00050913          	mv	s2,a0
8000122c:	00058993          	mv	s3,a1
80001230:	08000613          	li	a2,128
80001234:	00000593          	li	a1,0
80001238:	01010513          	addi	a0,sp,16
8000123c:	0a112623          	sw	ra,172(sp)
80001240:	0a812423          	sw	s0,168(sp)
80001244:	0a912223          	sw	s1,164(sp)
80001248:	1f4000ef          	jal	ra,8000143c <memset>
8000124c:	200007b7          	lui	a5,0x20000
80001250:	00478513          	addi	a0,a5,4 # 20000004 <RAM_BASE-0x5ffffffc>
80001254:	00a12623          	sw	a0,12(sp)
80001258:	10098663          	beqz	s3,80001364 <remove+0x148>
8000125c:	01010493          	addi	s1,sp,16
80001260:	00000413          	li	s0,0
80001264:	0180006f          	j	8000127c <remove+0x60>
80001268:	00412503          	lw	a0,4(sp)
8000126c:	02050863          	beqz	a0,8000129c <remove+0x80>
80001270:	00a4a023          	sw	a0,0(s1)
80001274:	00448493          	addi	s1,s1,4
80001278:	05340063          	beq	s0,s3,800012b8 <remove+0x9c>
8000127c:	00010593          	mv	a1,sp
80001280:	d19ff0ef          	jal	ra,80000f98 <parse_node>
80001284:	008957b3          	srl	a5,s2,s0
80001288:	0017f793          	andi	a5,a5,1
8000128c:	00140413          	addi	s0,s0,1
80001290:	fc079ce3          	bnez	a5,80001268 <remove+0x4c>
80001294:	00012503          	lw	a0,0(sp)
80001298:	fc051ce3          	bnez	a0,80001270 <remove+0x54>
8000129c:	0ac12083          	lw	ra,172(sp)
800012a0:	0a812403          	lw	s0,168(sp)
800012a4:	0a412483          	lw	s1,164(sp)
800012a8:	0a012903          	lw	s2,160(sp)
800012ac:	09c12983          	lw	s3,156(sp)
800012b0:	0b010113          	addi	sp,sp,176
800012b4:	00008067          	ret
800012b8:	00052783          	lw	a5,0(a0)
800012bc:	09010693          	addi	a3,sp,144
800012c0:	00241713          	slli	a4,s0,0x2
800012c4:	00e68733          	add	a4,a3,a4
800012c8:	f7c72703          	lw	a4,-132(a4)
800012cc:	fc07f793          	andi	a5,a5,-64
800012d0:	00f52023          	sw	a5,0(a0)
800012d4:	00072783          	lw	a5,0(a4)
800012d8:	fff40613          	addi	a2,s0,-1
800012dc:	00c956b3          	srl	a3,s2,a2
800012e0:	0016f693          	andi	a3,a3,1
800012e4:	fa079ce3          	bnez	a5,8000129c <remove+0x80>
800012e8:	00241413          	slli	s0,s0,0x2
800012ec:	80002737          	lui	a4,0x80002
800012f0:	ffc40413          	addi	s0,s0,-4
800012f4:	80070713          	addi	a4,a4,-2048 # 80001800 <_bss_end+0xffffff70>
800012f8:	00c10793          	addi	a5,sp,12
800012fc:	000808b7          	lui	a7,0x80
80001300:	fff80837          	lui	a6,0xfff80
80001304:	00870733          	add	a4,a4,s0
80001308:	fff88893          	addi	a7,a7,-1 # 7ffff <RAM_BASE-0x7ff80001>
8000130c:	00878433          	add	s0,a5,s0
80001310:	03f80813          	addi	a6,a6,63 # fff8003f <_bss_end+0x7ff7e7af>
80001314:	fff00513          	li	a0,-1
80001318:	0280006f          	j	80001340 <remove+0x124>
8000131c:	0107f7b3          	and	a5,a5,a6
80001320:	00f5a023          	sw	a5,0(a1)
80001324:	fff60613          	addi	a2,a2,-1
80001328:	00c956b3          	srl	a3,s2,a2
8000132c:	f6a608e3          	beq	a2,a0,8000129c <remove+0x80>
80001330:	0016f693          	andi	a3,a3,1
80001334:	ffc70713          	addi	a4,a4,-4
80001338:	ffc40413          	addi	s0,s0,-4
8000133c:	f60790e3          	bnez	a5,8000129c <remove+0x80>
80001340:	00072783          	lw	a5,0(a4)
80001344:	00042583          	lw	a1,0(s0)
80001348:	fff78793          	addi	a5,a5,-1
8000134c:	00f72023          	sw	a5,0(a4)
80001350:	0005a783          	lw	a5,0(a1)
80001354:	fc0694e3          	bnez	a3,8000131c <remove+0x100>
80001358:	0117f7b3          	and	a5,a5,a7
8000135c:	00f5a023          	sw	a5,0(a1)
80001360:	fc5ff06f          	j	80001324 <remove+0x108>
80001364:	0047a703          	lw	a4,4(a5)
80001368:	fc077713          	andi	a4,a4,-64
8000136c:	00e7a223          	sw	a4,4(a5)
80001370:	f2dff06f          	j	8000129c <remove+0x80>

80001374 <search>:
80001374:	fd010113          	addi	sp,sp,-48
80001378:	02912223          	sw	s1,36(sp)
8000137c:	00050493          	mv	s1,a0
80001380:	20000537          	lui	a0,0x20000
80001384:	01512a23          	sw	s5,20(sp)
80001388:	00450513          	addi	a0,a0,4 # 20000004 <RAM_BASE-0x5ffffffc>
8000138c:	00058a93          	mv	s5,a1
80001390:	00410593          	addi	a1,sp,4
80001394:	02812423          	sw	s0,40(sp)
80001398:	03212023          	sw	s2,32(sp)
8000139c:	01312e23          	sw	s3,28(sp)
800013a0:	01412c23          	sw	s4,24(sp)
800013a4:	02112623          	sw	ra,44(sp)
800013a8:	00060a13          	mv	s4,a2
800013ac:	00000413          	li	s0,0
800013b0:	be9ff0ef          	jal	ra,80000f98 <parse_node>
800013b4:	00000993          	li	s3,0
800013b8:	02000913          	li	s2,32
800013bc:	0084d7b3          	srl	a5,s1,s0
800013c0:	0017f793          	andi	a5,a5,1
800013c4:	00410593          	addi	a1,sp,4
800013c8:	00140413          	addi	s0,s0,1
800013cc:	06078263          	beqz	a5,80001430 <search+0xbc>
800013d0:	00812503          	lw	a0,8(sp)
800013d4:	00050c63          	beqz	a0,800013ec <search+0x78>
800013d8:	bc1ff0ef          	jal	ra,80000f98 <parse_node>
800013dc:	00c12783          	lw	a5,12(sp)
800013e0:	00078463          	beqz	a5,800013e8 <search+0x74>
800013e4:	00078993          	mv	s3,a5
800013e8:	fd241ae3          	bne	s0,s2,800013bc <search+0x48>
800013ec:	00399713          	slli	a4,s3,0x3
800013f0:	202007b7          	lui	a5,0x20200
800013f4:	00e787b3          	add	a5,a5,a4
800013f8:	0007a703          	lw	a4,0(a5) # 20200000 <RAM_BASE-0x5fe00000>
800013fc:	02c12083          	lw	ra,44(sp)
80001400:	02812403          	lw	s0,40(sp)
80001404:	00eaa023          	sw	a4,0(s5)
80001408:	0047a783          	lw	a5,4(a5)
8000140c:	00098513          	mv	a0,s3
80001410:	02412483          	lw	s1,36(sp)
80001414:	00fa2023          	sw	a5,0(s4)
80001418:	02012903          	lw	s2,32(sp)
8000141c:	01c12983          	lw	s3,28(sp)
80001420:	01812a03          	lw	s4,24(sp)
80001424:	01412a83          	lw	s5,20(sp)
80001428:	03010113          	addi	sp,sp,48
8000142c:	00008067          	ret
80001430:	00412503          	lw	a0,4(sp)
80001434:	fa0512e3          	bnez	a0,800013d8 <search+0x64>
80001438:	fb5ff06f          	j	800013ec <search+0x78>

8000143c <memset>:
8000143c:	0ff5f593          	andi	a1,a1,255
80001440:	00859793          	slli	a5,a1,0x8
80001444:	00b7e7b3          	or	a5,a5,a1
80001448:	01079593          	slli	a1,a5,0x10
8000144c:	00265613          	srli	a2,a2,0x2
80001450:	00f5e5b3          	or	a1,a1,a5
80001454:	00060e63          	beqz	a2,80001470 <memset+0x34>
80001458:	00261613          	slli	a2,a2,0x2
8000145c:	00c50633          	add	a2,a0,a2
80001460:	00050793          	mv	a5,a0
80001464:	00478793          	addi	a5,a5,4
80001468:	feb7ae23          	sw	a1,-4(a5)
8000146c:	fef61ce3          	bne	a2,a5,80001464 <memset+0x28>
80001470:	00008067          	ret

80001474 <start>:
80001474:	fc010113          	addi	sp,sp,-64
80001478:	800027b7          	lui	a5,0x80002
8000147c:	80002737          	lui	a4,0x80002
80001480:	02112e23          	sw	ra,60(sp)
80001484:	02812c23          	sw	s0,56(sp)
80001488:	02912a23          	sw	s1,52(sp)
8000148c:	80078693          	addi	a3,a5,-2048 # 80001800 <_bss_end+0xffffff70>
80001490:	89070713          	addi	a4,a4,-1904 # 80001890 <_bss_end+0x0>
80001494:	00e68a63          	beq	a3,a4,800014a8 <start+0x34>
80001498:	80078793          	addi	a5,a5,-2048
8000149c:	0007a023          	sw	zero,0(a5)
800014a0:	00478793          	addi	a5,a5,4
800014a4:	fee79ce3          	bne	a5,a4,8000149c <start+0x28>
800014a8:	a11ff0ef          	jal	ra,80000eb8 <init_uart>
800014ac:	80001537          	lui	a0,0x80001
800014b0:	7d050513          	addi	a0,a0,2000 # 800017d0 <_bss_end+0xffffff40>
800014b4:	875ff0ef          	jal	ra,80000d28 <printf_>
800014b8:	01800793          	li	a5,24
800014bc:	00f12223          	sw	a5,4(sp)
800014c0:	00300793          	li	a5,3
800014c4:	00f12423          	sw	a5,8(sp)
800014c8:	12345437          	lui	s0,0x12345
800014cc:	abcdb7b7          	lui	a5,0xabcdb
800014d0:	bcd78793          	addi	a5,a5,-1075 # abcdabcd <_bss_end+0x2bcd933d>
800014d4:	67840413          	addi	s0,s0,1656 # 12345678 <RAM_BASE-0x6dcba988>
800014d8:	00010513          	mv	a0,sp
800014dc:	00f12623          	sw	a5,12(sp)
800014e0:	00812023          	sw	s0,0(sp)
800014e4:	b39ff0ef          	jal	ra,8000101c <insert>
800014e8:	01c10613          	addi	a2,sp,28
800014ec:	01810593          	addi	a1,sp,24
800014f0:	00040513          	mv	a0,s0
800014f4:	e81ff0ef          	jal	ra,80001374 <search>
800014f8:	01c12603          	lw	a2,28(sp)
800014fc:	01812583          	lw	a1,24(sp)
80001500:	800014b7          	lui	s1,0x80001
80001504:	7e048513          	addi	a0,s1,2016 # 800017e0 <_bss_end+0xffffff50>
80001508:	821ff0ef          	jal	ra,80000d28 <printf_>
8000150c:	01800593          	li	a1,24
80001510:	00040513          	mv	a0,s0
80001514:	d09ff0ef          	jal	ra,8000121c <remove>
80001518:	01c10613          	addi	a2,sp,28
8000151c:	01810593          	addi	a1,sp,24
80001520:	00040513          	mv	a0,s0
80001524:	e51ff0ef          	jal	ra,80001374 <search>
80001528:	01c12603          	lw	a2,28(sp)
8000152c:	01812583          	lw	a1,24(sp)
80001530:	7e048513          	addi	a0,s1,2016
80001534:	ff4ff0ef          	jal	ra,80000d28 <printf_>
80001538:	0000006f          	j	80001538 <start+0xc4>

8000153c <__divsi3>:
8000153c:	06054063          	bltz	a0,8000159c <__umodsi3+0x10>
80001540:	0605c663          	bltz	a1,800015ac <__umodsi3+0x20>

80001544 <__udivsi3>:
80001544:	00058613          	mv	a2,a1
80001548:	00050593          	mv	a1,a0
8000154c:	fff00513          	li	a0,-1
80001550:	02060c63          	beqz	a2,80001588 <__udivsi3+0x44>
80001554:	00100693          	li	a3,1
80001558:	00b67a63          	bgeu	a2,a1,8000156c <__udivsi3+0x28>
8000155c:	00c05863          	blez	a2,8000156c <__udivsi3+0x28>
80001560:	00161613          	slli	a2,a2,0x1
80001564:	00169693          	slli	a3,a3,0x1
80001568:	feb66ae3          	bltu	a2,a1,8000155c <__udivsi3+0x18>
8000156c:	00000513          	li	a0,0
80001570:	00c5e663          	bltu	a1,a2,8000157c <__udivsi3+0x38>
80001574:	40c585b3          	sub	a1,a1,a2
80001578:	00d56533          	or	a0,a0,a3
8000157c:	0016d693          	srli	a3,a3,0x1
80001580:	00165613          	srli	a2,a2,0x1
80001584:	fe0696e3          	bnez	a3,80001570 <__udivsi3+0x2c>
80001588:	00008067          	ret

8000158c <__umodsi3>:
8000158c:	00008293          	mv	t0,ra
80001590:	fb5ff0ef          	jal	ra,80001544 <__udivsi3>
80001594:	00058513          	mv	a0,a1
80001598:	00028067          	jr	t0
8000159c:	40a00533          	neg	a0,a0
800015a0:	0005d863          	bgez	a1,800015b0 <__umodsi3+0x24>
800015a4:	40b005b3          	neg	a1,a1
800015a8:	f9dff06f          	j	80001544 <__udivsi3>
800015ac:	40b005b3          	neg	a1,a1
800015b0:	00008293          	mv	t0,ra
800015b4:	f91ff0ef          	jal	ra,80001544 <__udivsi3>
800015b8:	40a00533          	neg	a0,a0
800015bc:	00028067          	jr	t0

800015c0 <__modsi3>:
800015c0:	00008293          	mv	t0,ra
800015c4:	0005ca63          	bltz	a1,800015d8 <__modsi3+0x18>
800015c8:	00054c63          	bltz	a0,800015e0 <__modsi3+0x20>
800015cc:	f79ff0ef          	jal	ra,80001544 <__udivsi3>
800015d0:	00058513          	mv	a0,a1
800015d4:	00028067          	jr	t0
800015d8:	40b005b3          	neg	a1,a1
800015dc:	fe0558e3          	bgez	a0,800015cc <__modsi3+0xc>
800015e0:	40a00533          	neg	a0,a0
800015e4:	f61ff0ef          	jal	ra,80001544 <__udivsi3>
800015e8:	40b00533          	neg	a0,a1
800015ec:	00028067          	jr	t0
