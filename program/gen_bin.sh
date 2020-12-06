riscv64-unknown-elf-c++ -nostdlib -nostdinc -static -g -Ttext 0x80000000 $1.S -o $1.elf -march=rv32i -mabi=ilp32
riscv64-unknown-elf-objcopy -j .text -j '.text.*' -j .rodata -O binary -v $1.elf $1.bin
dd if=/dev/zero of=$1_4M.bin bs=1M count=4
# dd if=/dev/urandom of=$1_4M.bin bs=1M count=4
dd if=$1.bin of=$1_4M.bin conv=notrunc
rm $1.bin $1.elf

