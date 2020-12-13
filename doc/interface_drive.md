# 驱动文档

## 驱动的目标
* 实现`void receive(uint8_t* buffer, uint8_t src);`
* 与`void send(uint8_t* buffer, uint32_t len, uint8_t dst);`函数
* 其中`receive`函数作用为从`interface`中读取一帧的内容
* 而`send`函数作用为向`interface`中写入一帧的内容

## `receive`的实现

首先，我们知道`interface`给出CPU读取一帧的接口如下：

* `output wire cpu_read_start`
* `output wire [6:0] cpu_read_start_ptr`
* `input wire cpu_read_enb`
* `input wire [15:0] cpu_read_addrb`
* `output wire [31:0] cpu_read_doutb`
* `input wire cpu_read_end`
* `input wire [6:0] cpu_read_end_ptr`

其中，`cpu_read_start`是告诉CPU现在可读了，`cpu_read_start_ptr`是告诉CPU现在要读的是`BRAM`中的第几帧；`cpu_read_enb`，`cpu_read_addrb`与`cpu_read_doutb`分别是读使能、读地址与读数据；而`cpu_read_end`与`cpu_read_end_ptr`则是CPU读完之后告诉`interface`已经读完了和读完的是`BRAM`中的第几帧。

关于地址映射，我们预计将`128*2048bytes`的读地址映射到`0x60000000-0x6003FFFF`，其中`0x60000000-0x600007FF`为第0帧，`0x60000800-0x60000FFF`为第1帧，依此类推。

关于帧长度的问题，我们将在每一帧地址的最后两位标明帧的长度（字节），如`0x600007FE-0x600007FF`为第0帧的长度，依此类推。我们如此规定的话，就需要驱动文件**先读取长度，再读取内容**。

## `send`的实现

首先，我们知道`interface`给出CPU写入一帧的接口如下：

* `input wire cpu_write_enb`
* `input wire [3:0] cpu_write_web`
* `input wire [15:0] cpu_write_addrb`
* `input wire [31:0] cpu_write_dinb`
* `input wire cpu_write_end`
* `input wire [6:0] cpu_write_end_ptr`

其中，`cpu_write_enb`，`cpu_write_web`，`cpu_write_addrb`与`cpu_write_dinb`分别是使能，写使能、写地址与写数据；而`cpu_write_end`与`cpu_write_end_ptr`则是CPU写完之后告诉`interface`已经写完了和写完的是`BRAM`中的第几帧。

关于地址映射，我们预计将`128*2048bytes`的读地址映射到`0x60040000-0x6007FFFF`，其中`0x60040000-0x600407FF`为第0帧，`0x60040800-0x60040FFF`为第1帧，依此类推。

关于帧长度的问题，我们将在每一帧地址的最后两位标明帧的长度（字节），如`0x600007FE-0x600007FF`为第0帧的长度，依此类推。我们如此规定的话，就需要驱动文件**先写入内容，再写入长度**。

## 类串口设计

我们目前拟将`0x70000000, 0x70000010, 0x70000020`作为`cpu_read_start + cpu_read_start_ptr`、`cpu_read_end + cpu_read_end_ptr`还有`cpu_write_end + cpu_write_end_ptr`的虚拟地址