#include <sys/syscall.h>
#include <sys/uio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>

static char serial_read_char()
{
	while (!((*(volatile char *)0x10000005) & 0x1))
		;
	return *(volatile char *)0x10000000;
}

static void serial_write_char(char ch)
{
	while (!((*(volatile char *)0x10000005) & 0x20))
		;
	*(volatile char *)0x10000000 = ch;
}

static void serial_write_buf(const char *buf, size_t len)
{
	for (size_t i = 0; i < len; i++)
	{
		serial_write_char(buf[i]);
	}
}

static size_t duck_read(int fd, char *buf, size_t len)
{
	if (fd != 0)
	{
		return 0;
	}

	if (len > 0)
	{
		return (*buf = serial_read_char()), 1;
	}
	else
	{
		return 0;
	}
}

static size_t duck_write(int fd, const char *buf, size_t len)
{
	if (fd != 1 && fd != 2)
	{
		return 0;
	}

	serial_write_buf(buf, len);

	return len;
}

static size_t duck_readv(int fd, const struct iovec *iov, int cnt)
{
	size_t ret = 0;
	for (int i = 0; i < cnt; i++)
	{
		size_t tmp = duck_read(fd, (char *)iov[i].iov_base, iov[i].iov_len);
		if (tmp <= iov[i].iov_len)
		{
			ret += tmp;
		}
		if (tmp != iov[i].iov_len)
		{
			break;
		}
	}
	return ret;
}

static size_t duck_writev(int fd, const struct iovec *iov, int cnt)
{
	size_t ret = 0;
	for (int i = 0; i < cnt; i++)
	{
		size_t tmp = duck_write(fd, (const char *)iov[i].iov_base, iov[i].iov_len);
		if (tmp <= iov[i].iov_len)
		{
			ret += tmp;
		}
		if (tmp != iov[i].iov_len)
		{
			break;
		}
	}
	return ret;
}

static int duck_fstat(int fd, struct stat *st)
{
	memset(st, 0, sizeof(struct stat));
	if (fd == 0)
	{
		const size_t stdin_size = 0;
		st->st_mode = S_IFREG | 0644;
		st->st_size = stdin_size;
		st->st_blksize = 4096;
		st->st_blocks = (stdin_size + 4095) / 4096;
		return 0;
	}
	if (fd == 1)
	{
		const size_t stdout_size = 4096;
		st->st_mode = S_IFREG | 0644;
		st->st_size = stdout_size;
		st->st_blksize = 4096;
		st->st_blocks = (stdout_size + 4095) / 4096;
		return 0;
	}
	return -1;
}

extern char __bss_end;
static char *heap_brk = &__bss_end;

static char *read_sp()
{
	char *ret;
	__asm__ volatile("move %0, sp"
					 : "=r"(ret));
	return ret;
}

static char *duck_brk(char *addr)
{
	if (!addr)
	{
		return heap_brk;
	}
	if (addr > heap_brk && addr < addr + 0x1000 && addr + 0x1000 <= read_sp())
	{
		heap_brk = addr;
	}
	return heap_brk;
}

extern "C" long __duck_rv32i_syscall_handler(long a1, long a2, long a3, long, long, long, long, long n)
{
	switch (n)
	{
	case SYS_brk:
		return (long)duck_brk((char *)a1);
	case SYS_write:
		return duck_write((int)a1, (const char *)a2, (size_t)a3);
	case SYS_read:
		return duck_read((int)a1, (char *)a2, (int)a3);
	case SYS_readv:
		return duck_readv((int)a1, (const struct iovec *)a2, (int)a3);
	case SYS_writev:
		return duck_writev((int)a1, (const struct iovec *)a2, (int)a3);
	case SYS_ioctl:
		return 0;
	case SYS_fstat:
		return duck_fstat((int)a1, (struct stat *)a2);
	case SYS_set_tid_address:
		return 12345; // fake value
	case SYS_exit_group:
	case SYS_exit:
		printf("[Program exited with code %d]\n", a1);
		while (1)
			;
	default:
		return -1;
	}
}
