

with open("rip.txt","w") as F:
    for i in range(140, 160):
        for j in range(140, 160):
            F.write('''send(Ether(src=MAC_TESTER1) / IP(src=IP_TESTER1, dst=IP_RIP, ttl=1) / UDP() / RIP(version=2) /''')
            for k in range(25):
                if k < 24:
                    F.write("\tRIPEntry(addr='"+str(i)+"."+str(j)+"."+str(k)+".0', mask='255.255.255.0') /")
                else:
                    F.write("\tRIPEntry(addr='"+str(i)+"."+str(j)+"."+str(k)+".0', mask='255.255.255.0'))")
            F.write("\n\n")