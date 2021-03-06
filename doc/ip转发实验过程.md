电脑A连接0号口，0号卡端ip为170.170.170.0，电脑A端连接网卡ip设置为170.170.170.170。

电脑B连接1号口，1号卡端ip为187.187.187.0，电脑B端连接网卡ip设置为187.187.187.187。



我们先在A电脑上执行：

```bash
arping INTERFACE_A 170.170.170.0
```

再在B电脑上执行：

```bash
arping INTERFACE_B 187.187.187.0
```



两个arping指令都能正确返回相应的ARP回复，这两个操作的目的是在ARP Cache中写入我们电脑网卡的ip和mac地址对。



我们的固定转发表是这么写的：

```verilog
`timescale 1ns/1ps
module route_hard #(parameter PORT0 = 0,
                    parameter PORT1 = 1,
                    parameter PORT2 = 2,
                    parameter PORT3 = 3,
                    parameter IP0 = 32'haaaaaaaa,
                    parameter IP1 = 32'hbbbbbbbb,
                    parameter IP2 = 32'hcccccccc,
                    parameter IP3 = 32'hdddddddd,
                    parameter SUB_NET0 = 32'h000000a,
                    parameter SUB_NET1 = 32'h000000b,
                    parameter SUB_NET2 = 32'h000000c,
                    parameter SUB_NET3 = 32'h000000d,
                    parameter MASK = 32'h0000000f)
                   (input wire [31:0] q_ip,
                    output reg [31:0] q_nexthop,
                    output reg [2:0] q_port,
                    output reg q_valid);
    always @(*) begin
        case (q_ip & MASK)
            SUB_NET0:begin
                q_port    <= PORT0;
                q_nexthop <= IP0;
                q_valid   <= 1;
            end
            SUB_NET1:begin
                q_port    <= PORT1;
                q_nexthop <= IP1;
                q_valid   <= 1;
            end
            SUB_NET2:begin
                q_port    <= PORT2;
                q_nexthop <= IP2;
                q_valid   <= 1;
            end
            SUB_NET3:begin
                q_port    <= PORT3;
                q_nexthop <= IP3;
                q_valid   <= 1;
            end
            default: begin
                q_port    <= PORT0;
                q_nexthop <= IP0;
                q_valid   <= 0;
            end
        endcase
    end
    
endmodule

```



然后我们在电脑A上利用scapy发包，python代码如下：

```python
from scapy.all import *
dst = '187.187.187.187'
while True:
    send(IP(ttl=255, dst=dst), iface="enx000ec650a042")
```

按照转发逻辑，我们的板子应该受到一个dest ip=187.187.187.187的IP分组，然后会检查checksum，然后会减小ttl，然后他会在转发表中查询这个IP，得知这个IP的下一跳为`187.187.187.187 (bbbbbbbb)`，输出端口为1号口。ARP Cache中会查询这个ip的mac地址，由于我们之前已经写入，所以可以查到对应的MAC地址，所以最后应该能在电脑B端收到转发的IP包，但没有收到。

由于这个流程中间环节过多，我们是在不知道该怎么调试，所以请教您...