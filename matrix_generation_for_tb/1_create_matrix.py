import random

# matrix A - a x b  
# matrix B - b x c
a = int(input("give a: ")) 
b = int(input("give b: "))
c = int(input("give c: "))
d = int(input("give number of cores: "))

writeFile  = open('2_matrix_in.txt','w')

writeFile.write(str(a)+"\n"+str(b)+"\n"+str(c)+"\n"+str(d)+" //number of cores"+"\n")

writeFile.write("\n//matrix A\n")
out = ""
for x in range(a):
    temp = ""
    for y in range (b):
        temp+=(str(random.randint(0,5))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)

writeFile.write("\n//matrix B\n")

out = ""
for x in range(b):
    temp = ""
    for y in range (c):
        temp+=(str(random.randint(0,10))+" ")
    out+=(temp+"\n")

print (out)
writeFile.write(out)
writeFile.close()
# dataCode_translation()

