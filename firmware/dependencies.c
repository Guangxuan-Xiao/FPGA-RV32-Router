#include <stdint.h>
void *memset(void *s, int c, size_t sz)
{
    uint32_t *p = (uint32_t *)s;

    /* In this case the masking is actually important. */
    uint32_t x = c & 0xff;

    /* Construct a word's worth of the value we're supposed to be setting. */
    x |= x << 8;
    x |= x << 16;

    /* This technique (without a prologue and epilogue) will only cope with
     * sizes that are word-aligned. For example, you cannot use this function to
     * set a region 7 bytes long. Let's do some checks to make sure the size
     * passed is actually something we can cope with. It is worth noting that in
     * practice you would actually want to check the alignment of the start
     * pointer as well. Doing a word-wise memset on an unaligned pointer gains
     * you nothing and may even hurt performance.
     */
    sz >>= 2;          /* Divide by number of bytes in a word. */

    while (sz--)
        *p++ = x;
    return s;
}