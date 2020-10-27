# 两种内存分别共享版本

## Next-hop BRAM

| Address | IP Address   | Port |
| ------- | ------------ | ---- |
| 0       | `0`          | `0`  |
| 1       | `0xaaaaaaaa` | `0`  |
| 2       | `0xbbbbbbbb` | `1`  |
| 3       | `0xcccccccc` | `2`  |
| 4       | `0xdddddddd` | `3`  |

## Trie BRAM (All Shared)

| Address | Next-hop Address | LC Address | RC Address |
| ------- | ---------------- | ---------- | ---------- |
| 0       | 0                | 0          | 0          |

