lui x1, 0x20200
ori x2, zero, 10
lui x3, 0x12345
ori x3, x3, 0x600
write:
sw x3, 0(x1)
sw x3, 4(x1)
lw x4, 0(x1)
lw x4, 4(x1)
addi x1, x1, 8
addi x2, x2, -1
addi x3, x3, 1
bnez x2, write

lui x1, 0x20200
ori x2, zero, 64

read:
lw x4, 0(x1)
lw x4, 4(x1)
addi x1, x1, 8
addi x2, x2, -1
bnez x2, read
end:
j end