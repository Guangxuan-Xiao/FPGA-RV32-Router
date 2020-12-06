riscv64-unknown-elf-c++ -nostdlib -nostdinc -static -g -Ttext 0x80000000 $1.S -o $1.elf -march=rv32i -mabi=ilp32
riscv64-unknown-elf-objdump $1.elf -d > $1.d
rm $1.elf