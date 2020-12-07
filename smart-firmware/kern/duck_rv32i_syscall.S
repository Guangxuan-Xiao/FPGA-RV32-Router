.text
.globl __duck_rv32i_syscall

# to-save: ra, t0~t6, a0~a7
__duck_rv32i_syscall:
	addi sp, sp, -64  # 4 * 16
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
	sw t3, 12(sp)
	sw t4, 16(sp)
	sw t5, 20(sp)
	sw t6, 24(sp)
	sw a0, 28(sp)
	sw a1, 32(sp)
	sw a2, 36(sp)
	sw a3, 40(sp)
	sw a4, 44(sp)
	sw a5, 48(sp)
	sw a6, 52(sp)
	sw a7, 56(sp)
	sw ra, 60(sp)
	
	call __duck_rv32i_syscall_handler
	
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw t2, 8(sp)
	lw t3, 12(sp)
	lw t4, 16(sp)
	lw t5, 20(sp)
	lw t6, 24(sp)
	# no need to load a0 (return value)
	lw a1, 32(sp)
	lw a2, 36(sp)
	lw a3, 40(sp)
	lw a4, 44(sp)
	lw a5, 48(sp)
	lw a6, 52(sp)
	lw a7, 56(sp)
	lw ra, 60(sp)
	addi sp, sp, 64
	
	ret
