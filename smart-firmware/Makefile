kernel_elf := build/smart-kernel.elf
kernel_bin := build/smart-kernel.bin
kernel_obj := build/smart-kernel.obj
firmware_elf := build/smart-firmware.elf
firmware_bin := build/smart-firmware.bin
loader_obj := build/loader/loader.o
loader_cpp := loader/loader.cpp

TARGET := riscv64-unknown-elf-

LIB_PREFIX := ../riscv32i-duck-prebuilt/

CXX := $(TARGET)g++
CXX += -std=c++14
CXX += -Wall -Wextra -march=rv32i -mabi=ilp32
CXX += -U_FORTIFY_SOURCE
CXX += -I .
CXX += -I $(LIB_PREFIX)include/
CXX += -static -nostdlib -fno-builtin -nostdinc

LD := $(TARGET)ld -melf32lriscv -static -nostdlib

OBJCOPY := $(TARGET)objcopy

kernel_linker_script := kernel.ld
firmware_linker_script := firmware.ld
boot_asm_source_files := $(wildcard boot/*.S)
boot_asm_object_files := $(patsubst boot/%.S, \
		build/boot/%.o, $(boot_asm_source_files))

kern_asm_source_files := $(wildcard kern/*.S)
kern_asm_object_files := $(patsubst kern/%.S, \
		build/kern/%.o, $(kern_asm_source_files))

header_files := $(wildcard inc/*.h) $(wildcard inc/*.hpp)
LIBC_PREFIX := $(LIB_PREFIX)musl/
LIBGCC_PREFIX := $(LIB_PREFIX)libgcc/
libstdcxx_files := $(LIB_PREFIX)libstdc++/libstdc++.a
libc_files := -L $(LIBC_PREFIX) -L $(LIBGCC_PREFIX) -lc -lgcc -lc
libc_crt_start := $(LIBC_PREFIX)crt1.o $(LIBC_PREFIX)crti.o $(LIBGCC_PREFIX)crtbegin.o
libc_crt_end := $(LIBGCC_PREFIX)crtend.o $(LIBC_PREFIX)crtn.o

all: $(kernel_bin) $(firmware_bin)

include kern/Makefile

.PHONY: all clean run

clean:
	@rm -r build/*

QEMUOPTS ?= ""

run: $(kernel_bin) $(kernel_elf) $(firmware_bin) $(firmware_elf)
	@qemu-system-riscv32 -machine virt -nographic -m 8M -kernel $(firmware_elf) -bios none -serial mon:stdio $(QEMUOPTS)

$(kernel_elf): $(boot_asm_object_files) $(kern_object_files) $(kernel_linker_script) $(kern_asm_object_files)
	@echo + ld $@
	@$(LD) -n -T $(kernel_linker_script) -o $(kernel_elf) \
		$(libc_crt_start) $(boot_asm_object_files) $(kern_asm_object_files) $(kern_object_files) \
		$(libstdcxx_files) $(libc_files) $(libc_crt_end)

$(kernel_bin): $(kernel_elf)
	@echo + objcopy $@
	@$(OBJCOPY) -S --adjust-vma -0x80100000 -O binary $< $@

$(kernel_obj): $(kernel_bin)
	@echo + ld-binary $@
	@$(LD) -r -b binary -o $@ $<

$(firmware_elf): $(kernel_obj) $(loader_obj) $(firmware_linker_script)
	@echo + ld $@
	@$(LD) -n -T $(firmware_linker_script) -o $(firmware_elf) \
		$(loader_obj) $(kernel_obj)

$(firmware_bin): $(firmware_elf)
	@echo + objcopy $@
	@$(OBJCOPY) -S --adjust-vma -0x80000000 -O binary $< $@

$(loader_obj): $(loader_cpp)
	@echo + cxx $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -c $< -o $@

build/boot/%.o: boot/%.S
	@echo + as $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -c $< -o $@

build/kern/%.o: kern/%.S
	@echo + as $@
	@mkdir -p $(shell dirname $@)
	@$(CXX) -c $< -o $@
