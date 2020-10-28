from bitrie import BiTrie
DEPTH = 2**13
trie = BiTrie()

trie.add("170.0.0.0", 8, 1)
trie.add("187.0.0.0", 8, 2)
trie.add("204.0.0.0", 8, 3)
trie.add("221.0.0.0", 8, 4)
print("memory_initialization_radix=2;")  # 数据以16进制格式存储
print("memory_initialization_vector=", end="")
print("0", end=",")
trie.PreOrderTraverse(mode="bram")
print("0;")
