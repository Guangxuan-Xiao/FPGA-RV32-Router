FILENAME = "1.coe"
DEPTH = 256

file = open(FILENAME, "w+")
file.write("memory_initialization_radix=16;\n") # 数据以16进制格式存储
file.write("memory_initialization_vector=0,aaaaaaaa,1bbbbbbbb,2cccccccc,3dddddddd")
for i in range(5, DEPTH):
    file.write(",0")
file.write(";")
file.close()