lui x1, 0x20000
lui x2, 0x00008
ori x3, zero, 33
write:
sw x3, 8(x1)
lw x5, 8(x1)
add x1, x1, x2
addi x3, x3, -1
bnez x3, write

lui x1, 0x20000
lui x2, 0x00008
ori x3, zero, 33

read:
lw x5, 8(x1)
add x1, x1, x2
addi x3, x3, -1
bnez x3, read
end:
j end