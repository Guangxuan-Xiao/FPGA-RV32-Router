from bitrie import BiTrie
DEPTH = 2**13
trie = BiTrie()

trie.add(0x55000000, 8, 1)  # 0xaa000000
trie.add(0xdd000000, 8, 2)  # 0xbb000000
trie.add(0x33000000, 8, 3)  # 0xcc000000
trie.add(0xbb000000, 8, 4)  # 0xdd000000
print("memory_initialization_radix=2;")  # 数据以16进制格式存储
print("memory_initialization_vector=", end="")
print("0", end=",")
ret = trie.PreOrderTraverse(mode="bram")
for node in ret:
    print(node["data"], end=",")
print("0;")
