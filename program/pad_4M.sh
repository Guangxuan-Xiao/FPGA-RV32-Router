dd if=/dev/zero of=$1_4M.bin bs=1M count=4
# dd if=/dev/urandom of=$1_4M.bin bs=1M count=4
dd if=$1.bin of=$1_4M.bin conv=notrunc
rm $1.bin $1.elf

