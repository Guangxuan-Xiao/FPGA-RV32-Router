lui x1, 0x20000
lui x2, 0x00008
ori x3, zero, 33
lui x4, 0x12345
ori x4, x4, 0x678
trie:
sw x4, 0(x1)
lw x5, 0(x1)
add x1, x1, x2
addi x3, x3, -1
bnez x3, trie
end:
j end