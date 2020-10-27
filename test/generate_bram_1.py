from math import *
from matplotlib import pyplot as plt # 用于预览生成的波形

# FILENAME = "512_square.coe" # 方波
# FILENAME = "512_sine.coe" # 正弦波
# FILENAME = "512_ramp.coe" # 锯齿波
FILENAME = "512_triangle.coe"  # 三角波
WIDTH = 8
DEPTH = 512

hex_table = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']
points = []
out = []

file = open(FILENAME, "w+")
file.write("memory_initialization_radix=16;\n") # 数据以16进制格式存储
file.write("memory_initialization_vector=")
base = 2**(WIDTH - 1) - 1

for i in range(DEPTH):

    # var = int(base + (-1 if i >= DEPTH // 2 else 1) * base) # 方波
    # var = int(base + sin(i / DEPTH * 2 * pi) * base) # 正弦波
    # var = int(i / DEPTH * (2 ** WIDTH - 1)) # 锯齿波
    var = int((1 - abs((i * 2 / (DEPTH - 1)) - 1)) * (2**WIDTH - 1))  # 三角波

    if var >= 2**WIDTH: # 抹平超出范围的数据
        var = 2**WIDTH - 1
    points.append(var)

    var_hex = ""
    while (var > 0):
        var_hex += hex_table[var & 0xf] # 取低4位并转换为16进制存入var_hex中
        var >>= 4 # 右移去掉已处理的4位
    var_hex += '0' * ((WIDTH - 1) // 4 - len(var_hex) + 1) # 根据WIDTH补零
    out.append(var_hex[::-1]) # 将var_hex中的内容翻转

for i in range(DEPTH):  # 逆序存入文件
    print(out[DEPTH - i - 1], end=" ")
    file.write(out[DEPTH - i - 1] + " ")

file.close()
plt.plot(points) # 用于预览生成的波形
plt.show() # 用于预览生成的波形