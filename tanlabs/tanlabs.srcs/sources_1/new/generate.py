
with open("out.txt","w") as F:
    for i in range(2, 34):
        F.write("frame_data query_trie_"+str(i)+";\n")
        F.write("wire query_trie_"+str(i)+"_ready;\n")
        F.write("assign query_trie_"+str(i-1)+"_ready = query_trie_"+str(i)+"_ready || !query_trie_"+str(i-1)+".valid;\n")
        F.write("always @ (posedge eth_clk or posedge reset)\n")
        F.write("begin\n")
        F.write("\tif (reset)\n")
        F.write("\tbegin\n")
        F.write("\t\tquery_trie_"+str(i)+" <= 0;\n")
        F.write("\tend\n")
        F.write("\telse if (query_trie_"+str(i)+"_ready)\n")
        F.write("\tbegin\n")
        F.write("\t\tquery_trie_"+str(i)+" <= query_trie_"+str(i-1)+";\n")
        F.write("\tend\n")
        F.write("end\n")
        F.write("\n\n")
    