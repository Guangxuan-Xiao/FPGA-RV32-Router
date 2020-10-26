# Trie路由表设计文档

目前是最简单的二进制Trie路由表，之后可以尝试步长为K的多分支Trie。

## 符号定义

| 符号  | 含义                                                         |
| ----- | ------------------------------------------------------------ |
| $W_E$ | 路由表项地址宽度（**E**ntry Address **W**idth），即我们的路由表能够存储$2^{W_E}$个路由表项。 |
| $W_T$ | Trie节点地址宽度（**T**rie Node Address **W**idth），即我们的Trie树最多有$2^{W_T}$个节点。 |

## 约束

如果我们的路由表能够存储$2^{W_E}$个路由表项，那么需要Trie节点个数的一个上界为$32\times2^{W_E}$.

因此有不等式：
$$
2^{W_T} \ge 32\times2^{W_E} = 2^{W_E+5}
$$
解得我们只要令$W_T \ge W_E + 5$，就能保证能够用Trie树把开的路由表地址空间完全表示。

## 存储

### 路由表项内存空间

这个内存空间用来存储`<nexthop, port>`对，将其设计为共享内存，便与软件访问，也就是说设计成双口BRAM，一端用于硬件读写，一端留给软件读写。

这个空间的长为$2^{W_E}$，宽为$32+3 = 35$。

其中每行是这样一个`struct`:

```verilog
typedef struct packed {
    logic[31:0] nexthop;
    logic[2:0]  port;
} Entry;
```

一共有$2^{W_E}$行，因此我们可以用一个字宽为$W_E$的地址索引到一个路由表项。

### Trie节点内存空间

这个内存空间用来存储Trie树的节点，不需要软件访问，可以设计成单口BRAM。

这个空间的长为$2^{W_T}$，宽为$W_E + 2\times W_T$。

其中每行是这样一个`struct`:

```verilog
typedef struct packed {
    logic[W_E-1:0] entryAddr;
    logic[W_T-1:0] lcAddr;
    logic[W_T-1:0] rcAddr;
} TrieNode;
```

一共有$2^{W_T}$行，因此我们可以用一个字宽为$W_T$的地址索引到一个Trie Node。

## 算法

### 约定

- 两个地址空间的首地址（地址为0）的内存我们都不用，这样当`entryAddr`为0我们就知道这个Trie Node不对应路由表项，当`lcAddr`或`rcAddr`为0我们就知道没有左or右孩子。
- 地址为1的Trie Node是整个Trie树的根节点。

### 查找



### 删除

- 输入
```verilog
input wire[31:0] ip_addr
input wire[4:0] len 
```

- 功能

  精确匹配找到前缀长度为`len`，前缀为`ip_addr[len-1:0]`的路由表项，将其删除。

### 插入

- 输入

```verilog
input wire[31:0] ip_addr
input wire[4:0] len 
```

- 功能

  精确匹配找到前缀长度为`len`，前缀为`ip_addr[len-1:0]`的路由表项，将其删除。

## 复杂度计算

### 空间复杂度

$Memory \ge 35\times 2^{W_E} + (3W_E+10)\times2^{W_E+5} bit$

如果我们要存$2^{12} = 4096$条路由表，即$W_E=12$，那么我们需要的空间为：$6172Kib = 772KiB$，BRAM是存得下的。

### 时间复杂度