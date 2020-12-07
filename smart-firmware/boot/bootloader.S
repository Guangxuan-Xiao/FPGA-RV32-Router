.section .text.boot
.globl __bootloader_start

__bootloader_start:
    la a1, bootloader_message
    
write_message_loop:
    lb a0, (a1)
    beq a0, zero, write_message_end
    call write_serial
    addi a1, a1, 1
    j write_message_loop
write_message_end:

init_bss:
    la a0, __bss_start
    la a1, __bss_end
1:
    sw zero, (a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
    
init_tbss:
    la a0, __tbss_start
    la a1, __tbss_end
1:
    sw zero, (a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
    
init_stack:
    la sp, 0x80800000   # 8M

init_arguments:
    addi sp, sp, -16
    sw zero, 12(sp)   # auxv end
    sw zero, 8(sp)    # envp end
    sw zero, 4(sp)    # argv end
    sw zero, 0(sp)    # argc

jump_to_libc:
    j _start
    # Should never return

spin:
    j spin


write_serial:                       # 写串口：将a0的低八位写入串口
    li t0, 0x10000000
1:
    lb t1, %lo(5)(t0)               # 查看串口状态
    andi t1, t1, 0x20               # 截取写状态位
    bne t1, zero, .wserial          # 状态位非零可写进入写
    j 1b                            # 检测验证，忙等待
.wserial:
    sb a0, %lo(0)(t0)               # 写入寄存器a0中的值
    jr ra

bootloader_message:
    .asciz "Smart-firmware for riscv32i booting...\n"
