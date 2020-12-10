#include <stdint.h>

char stack[128] __attribute__((aligned(16)));

asm (R"(
	.text
	.globl _start
	
	_start:
		la sp, stack + 128
		j main
)");

static void serial_write_char(char ch) {
	while (!((* (volatile char *) 0x10000005) & 0x20));
	* (volatile char *) 0x10000000 = ch;
}

static void serial_write_buf(const char *buf) {
	while (*buf) {
		serial_write_char(*buf);
		buf++;
	}
}

static void copy(char *dst, const char *src, uint32_t len) {
	while (len--) {
		*(dst++) = *(src++);
	}
}

#define bin_start _binary_build_smart_kernel_bin_start
#define bin_end _binary_build_smart_kernel_bin_end
#define kernel_addr 0x80100000

int main() {
	extern char bin_start[];
	extern char bin_end[];
	char *kernel = (char *) kernel_addr;
	
	serial_write_buf("Loading...");
	
	copy(kernel, bin_start, bin_end - bin_start);
	
	serial_write_buf("OK\n");
	
	((void (*)()) kernel)();  // should never return
	
	while (1);
}
