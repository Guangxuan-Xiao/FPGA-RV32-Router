import ipaddress


class Node():
    def __init__(self, bit=None, network=None, prefix_len=None, next_hop=None, lchild=None, rchild=None):
        self.bit = bit
        self.next_hop = next_hop
        self.network = network
        self.prefix_len = prefix_len
        self.lchild = lchild
        self.rchild = rchild

# 使用二叉trie实现路由表


class BiTrie():
    def __init__(self):
        # 根节点bit和next_hop为空,可以用来存放缺省路由,目前没有支持
        self.root = Node()

    # 添加路由或者修改路由的下一跳
    def add(self, network, prefix_len, next_hop):
        # parent是每次循环要操作（可能只是经过，也可能是存储路由）的结点current_node的父节点，
        # 从root开始向下进行操作
        parent = self.root
        # 提取前缀
        prefix = (int(ipaddress.IPv4Address(network))) >> (32-prefix_len)
        for i in range(prefix_len-1, -1, -1):
            # 从高到低，逐bit处理
            # 对于最高位bit不需要&0x1,但是其它bit需要
            bit = (prefix >> i) & 0x1
            # print(bit)

            if bit == 0:
                if not parent.lchild:
                    # 左孩子不存在，则新建左孩子结点
                    parent.lchild = Node(bit=bit)
                # 如果左孩子存在，它可能用于存储路由，也可能只是提供路径，不过这里不区分（除了i==0时）
                # 即是否有掩码短，包含了当前network的路由，并不区分
                current_node = parent.lchild
            elif bit == 1:
                if not parent.rchild:
                    parent.rchild = Node(bit=bit)
                current_node = parent.rchild

            # 当前结点current_node成为下次循环的parent
            parent = current_node

        # 存储最后一个bit的结点存储路由信息，i==0时循环结束
        # 虽然代码上没有区别，但是功能上实现了添加和修改下一跳的两种情况，具体是添加还是修改，取决于软件的数据状态（亦即取决于代码的执行路径）
        current_node.bit = bit
        current_node.network = network
        current_node.prefix_len = prefix_len
        current_node.next_hop = next_hop

        # print(node.next_hop)

    # 路由查找,实现最长掩码匹配，可以根据DIP，也可以根据Dst network查询
    def search(self, network, prefix_len):
        # 存储匹配到的路由的下一跳
        next_hops = []
        # parent是每次循环要操作（可能只是经过，也可能是记录路由下一跳）的结点current_node的父节点，
        # 从root开始向下进行操作
        parent = self.root
        prefix = (int(ipaddress.IPv4Address(network))) >> (32-prefix_len)
        for i in range(prefix_len-1, -1, -1):
            bit = (prefix >> i) & 1
            # print(bit)
            if bit == 0:
                # 左孩子中可能存储着路由，也可能只是为子孙节点提供路径
                if parent.lchild:
                    current_node = parent.lchild
                # 可能匹配失败，或者通过next_hops[-1]可以获取到掩码最长的路由的下一跳
                else:
                    break
            elif bit == 1:
                if parent.rchild:
                    current_node = parent.rchild
                else:
                    break
            # 如果该结点存储了路由，则记录路由的下一跳
            if current_node.next_hop:
                next_hops.append(current_node.next_hop)
                # print(current_node.next_hop)

            # 当前结点current_node成为下次循环的parent
            parent = current_node

        # print(next_hops)
        # 如果有多个下一跳，返回掩码最长的network对应的下一跳
        if next_hops:
            return next_hops[-1]
        else:
            return None

    # 删除路由
    def delete(self, network, prefix_len):
        if not self.search(network, prefix_len):
            print("The route you want to delete dose not exist!")
            return -1
        layer_path = []
        parent = self.root
        prefix = (int(ipaddress.IPv4Address(network))) >> (32-prefix_len)
        for i in range(prefix_len-1, -1, -1):
            bit = (prefix >> i) & 1
            # 因为上面已经检查了精确路由存在，所以需要的孩子结点一定存在
            if bit == 0:
                node = parent.lchild
            elif bit == 1:
                node = parent.rchild

            layer_path.append(node)
            parent = node

        # 这个时候i==0，node是最后一个bit对应的结点
        node.network = None
        node.prefix_len = None
        node.next_hop = None

        # 回溯删除不再需要的结点
        for i in range(len(layer_path)-1, -1, -1):
            if not layer_path[i].lchild and not layer_path[i].rchild and not layer_path[i].next_hop:
                if layer_path[i].bit == 0:
                    layer_path[i-1].lchild = None
                else:
                    layer_path[i-1].rchild = None
            # 遇到一个结点不能删除，则停止回溯，这样可以提高性能
            else:
                break

    # 打印路由表，先序遍历整棵树，先打印root，然后递归遍历左右子树（需要先将左右孩子转换成树）
    def PreOrderTraverse(self):
        parent = self.root
        if parent.next_hop:
            print("{0}/{1} {2}".format(parent.network,
                                       parent.prefix_len, parent.next_hop))
        if parent.lchild:
            lchild_trie = BiTrie()
            lchild_trie.root = parent.lchild
            lchild_trie.PreOrderTraverse()
        if parent.rchild:
            rchild_trie = BiTrie()
            rchild_trie.root = parent.rchild
            rchild_trie.PreOrderTraverse()


trie = BiTrie()

'''
输出为：
5.5.5.5
8.8.8.8
2.2.2.2
128.0.0.0 2.2.2.2
224.0.0.0 5.5.5.5
228.0.0.0 8.8.8.8
2.2.2.2
8.8.8.8
2.2.2.2
128.0.0.0 2.2.2.2
228.0.0.0 8.8.8.8
'''
# 不考虑IP地址的分类
trie.add("224.0.0.0", 3, "5.5.5.5")
trie.add("228.0.0.0", 6, "8.8.8.8")
trie.add("128.0.0.0", 1, "2.2.2.2")
print(trie.search("224.0.0.0", 3))
print(trie.search("228.0.0.0", 6))
print(trie.search("128.0.0.0", 1))
trie.PreOrderTraverse()
trie.delete("224.0.0.0", 3)
print(trie.search("224.0.0.0", 3))
print(trie.search("228.0.0.0", 6))
print(trie.search("128.0.0.0", 1))
trie.PreOrderTraverse()
